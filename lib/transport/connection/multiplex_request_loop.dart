part of connection;

class MultiplexRequestLoop {
  static const int errByte = 0x2F;
  static const int okByte = 0x20;
  final Connection _connection;
  final _requests = <int, _RequestCompleter>{};
  late final StreamSubscription<r.BytesBuffer> _subscription;
  var _lastRequestId = 0;

  MultiplexRequestLoop(this._connection) {
    _subscription = _connection.read.listen(
      _handleRead,
      onError: _handleReadError,
    );
  }

  Future<void> close() => _subscription.cancel();

  Future<T> sendRequest<T extends Message>(HandlerHash hash, Message request, T response) async {
    final builder = BytesBuilder(copy: false);
    builder.addByte(newProtocolByte());
    builder.add(hash.hash);
    builder.add(request.Marshal());

    final requestCompleter = _RequestCompleter(response);
    final id = ++_lastRequestId;
    _requests[id] = requestCompleter;

    final data = w.Data(builder.toBytes());
    final bytes = w.BytesBuffer()
      ..add(w.RequestId(id))
      ..add(data);
    _connection.write(bytes);

    return requestCompleter.future;
  }

  void _handleRead(r.BytesBuffer message) {
    final bytes = message.add(const r.DataApplier()).data;
    final requestId = message.properties.whereType<r.Multiplex>().first.requestId;
    final request = _requests.remove(requestId)!;
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

class _RequestCompleter<T extends Message> {
  final T response;
  final _completer = Completer<T>();

  _RequestCompleter(this.response);

  Future<T> get future => _completer.future;

  void unmarshal(Uint8List bytes) {
    try {
      response.Unmarshal(BinaryIterator(bytes));
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
