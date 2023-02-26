import 'dart:async';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/client/conv.dart';
import 'package:crypto_chateau_dart/transport/connection/connection.dart';
import 'package:crypto_chateau_dart/transport/handler.dart';
import 'package:crypto_chateau_dart/transport/meta.dart';
import 'package:crypto_chateau_dart/transport/multiplex_connection.dart';

class MultiplexRequestLoop {
  static const int errByte = 0x2F;
  static const int okByte = 0x20;
  final MultiplexConnection _connection;
  final _requests = <int, _RequestCompleter>{};
  late final StreamSubscription<MultiplexMessage> _subscription;
  var _lastRequestId = 0;

  MultiplexRequestLoop(this._connection) {
    _subscription = _connection.read.listen(
      _handleRead,
      onError: _handleReadError,
    );
  }

  Future<void> close() => _subscription.cancel();

  Future<T> sendRequest<T extends Response>(Request<T> request) async {
    final requestCompleter = _RequestCompleter(request);
    final id = ++_lastRequestId;
    _requests[id] = requestCompleter;
    print('PEER: ${MultiplexMessage(id, request.marshal()).toBytes()}');
    _connection.write(MultiplexMessage(id, request.marshal()));

    return requestCompleter.future;
  }

  void _handleRead(MultiplexMessage message) {
    final bytes = message.bytes;
    final request = _requests.remove(message.requestId)!;
    final serverRespMetaInfo = getServerRespMetaInfo(bytes);
    final offset = serverRespMetaInfo.payloadOffset;

    if (bytes[offset] == errByte) {
      request.completeError(MultiplexRequestLoopRPCError(bytes));
    }

    if (offset + 1 + bytes.length < objectBytesPrefixLength) {
      request.completeError(const MultiplexRequestLoopSizeError());
    }

    request.unmarshal(bytes.sublist(offset + 1 + objectBytesPrefixLength));
  }

  void _handleReadError(Object error, StackTrace stackTrace) {
    if (error is ConnectionErrorFatal) {
      for (var request in _requests.values) {
        request.completeError(error, stackTrace);
      }

      _requests.clear();
    }
  }
}

class _RequestCompleter<T extends Response> {
  final Request<T> request;
  final _completer = Completer<T>();

  _RequestCompleter(this.request);

  Future<T> get future => _completer.future;

  void unmarshal(Uint8List bytes) {
    try {
      final response = request.unmarshal(bytes);
      _completer.complete(response);
    } on Object catch (e, st) {
      completeError(e, st);
    }
  }

  void completeError(Object error, [StackTrace? stackTrace]) => _completer.completeError(error, stackTrace);
}

abstract class Response {}

abstract class Request<T extends Response> {
  HandlerHash get handlerHash;

  Uint8List marshal();

  T unmarshal(Uint8List bytes);
}

class MultiplexRequestLoopRPCError implements Exception {
  final Uint8List bytes;

  const MultiplexRequestLoopRPCError(this.bytes);

  @override
  String toString() => '$runtimeType: status = error, description = ${String.fromCharCodes(bytes.sublist(2))}';
}

class MultiplexRequestLoopSizeError implements Exception {
  const MultiplexRequestLoopSizeError();

  @override
  String toString() => '$runtimeType: not enough for size and message';
}
