import 'dart:collection';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/client/binary_iterator.dart';
import 'package:crypto_chateau_dart/client/conv.dart';
import 'package:crypto_chateau_dart/client/models.dart';
import 'package:crypto_chateau_dart/transport/connection.dart';
import 'package:crypto_chateau_dart/transport/handler.dart';
import 'package:crypto_chateau_dart/transport/meta.dart';
import 'package:crypto_chateau_dart/transport/multiplex_conn.dart';
import 'package:crypto_chateau_dart/version/version.dart';
import 'dart:async';
import 'dart:math';

import 'package:x25519/x25519.dart';

class Peer {
  static const int errByte = 0x2F;
  static const int okByte = 0x20;
  final Connection _connection;
  final _responseQueue = Queue<_Response>();
  late final StreamSubscription<Uint8List> _subscription;
  Future<void>? _handshake;

  Peer(this._connection) {
    _subscription = _connection.read.listen(_handleRead);
  }

  Future<void> close() => _subscription.cancel();

  Future<T> sendRequest<T extends Message>(
    HandlerHash handlerHash,
    Message requestMessage,
    T responseMessage,
  ) async {
    if (_handshake == null) {
      final completer = Completer<void>();

      try {
        await _doHandshake();
        completer.complete();
      } on Object catch (e, st) {
        completer.completeError(e, st);
      }
    }

    await _handshake;

    return _sendRequest(
        (BytesBuilder(copy: false)
              ..addByte(newProtocolByte())
              ..add(handlerHash.hash)
              ..add(requestMessage.Marshal()))
            .takeBytes(),
        responseMessage);
  }

  Future<T> _sendRequest<T extends Message>(
    Uint8List request,
    T response,
  ) async {
    final $response = _Response(response);
    _responseQueue.add($response);
    _connection.write(request);

    return $response.future;
  }

  void _handleRead(Uint8List bytes) {
    final response = _responseQueue.removeFirst();
    final serverRespMetaInfo = getServerRespMetaInfo(bytes);
    final offset = serverRespMetaInfo.payloadOffset;

    if (bytes[offset] == errByte) {
      response.completeError(ChateauRPCError(bytes));
    }

    if (offset + 1 + bytes.length < objectBytesPrefixLength) {
      response.completeError(const ChateauSizeError());
    }

    try {
      response.message.Unmarshal(BinaryIterator(bytes.sublist(offset + 1 + objectBytesPrefixLength)));
    } on Object catch (e, st) {
      response.completeError(e, st);
    }

    response.complete();
  }

  Future<void> _doHandshake() async {
    final publicKey = (await _sendRequest(
      Uint8List.fromList([104, 97, 110, 100, 115, 104, 97, 107, 101]),
      PublicKeyResponse(publicKey: Uint8List(0)),
    ))
        .publicKey;
    var privateKey = Uint8List(32);
    var secureRandom = Random.secure();
    for (var i = 0; i < privateKey.length; i++) {
      privateKey[i] = secureRandom.nextInt(256);
    }

    privateKey[0] &= 248;
    privateKey[31] &= 63;
    privateKey[31] |= 64;

    final message = (await _sendRequest(
      X25519(privateKey, basePoint),
      HandshakeResponse(message: Uint8List(0)),
    ))
        .message;

    if (message[0] != 49) {
      throw Exception('expected success handshake message from server');
    }

    _connection.encryptionKey = X25519(privateKey, publicKey);
  }
}

class _Response<T extends Message> {
  final T message;
  final _completer = Completer<T>();

  _Response(this.message);

  Future<T> get future => _completer.future;

  void complete() => _completer.complete(message);

  void completeError(Object error, [StackTrace? stackTrace]) => _completer.completeError(error, stackTrace);
}

class PublicKeyResponse implements Message {
  Uint8List publicKey;

  PublicKeyResponse({
    required this.publicKey,
  });

  @override
  Uint8List Marshal() => publicKey;

  @override
  void Unmarshal(BinaryIterator b) => publicKey = Uint8List.fromList(b.bytes);
}

class HandshakeRequest implements Message {
  Uint8List publicKey;

  HandshakeRequest({
    required this.publicKey,
  });

  @override
  Uint8List Marshal() => publicKey;

  @override
  void Unmarshal(BinaryIterator b) {}
}

class HandshakeResponse implements Message {
  Uint8List message;

  HandshakeResponse({
    required this.message,
  });

  @override
  Uint8List Marshal() => message;

  @override
  void Unmarshal(BinaryIterator b) => message = Uint8List.fromList(b.bytes);
}

class ChateauRPCError implements Exception {
  final Uint8List bytes;

  const ChateauRPCError(this.bytes);

  @override
  String toString() => '$runtimeType: status = error, description = ${String.fromCharCodes(bytes.sublist(2))}';
}

class ChateauSizeError implements Exception {
  const ChateauSizeError();

  @override
  String toString() => '$runtimeType: not enough for size and message';
}
