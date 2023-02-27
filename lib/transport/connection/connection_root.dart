part of connection;

class ConnectParams {
  final String host;
  final int port;
  final bool isEncryptionEnabled;

  ConnectParams({
    required this.host,
    required this.port,
    required this.isEncryptionEnabled,
  });
}

class ConnectionRoot implements Connection {
  final ConnectParams connectParams;
  final _readController = StreamController<r.BytesBuffer>(sync: true);
  StreamSubscription<Uint8List>? _socketSubscription;
  Completer<Socket>? _socket;
  var _closed = false;

  ConnectionRoot(this.connectParams);

  Future<void> close() async {
    if (_closed) return;

    _closed = true;
    await _socketSubscription?.cancel();
    await _readController.close();
    (await _socket?.future)?.destroy();
  }

  @override
  Stream<r.BytesBuffer> get read => _readController.stream;

  @override
  void write(w.BytesBuffer bytes) => _initSocket().then(
        (socket) => socket.add(bytes.toBytes()),
        onError: _readController.addError,
      );

  Future<Socket> _initSocket() {
    if (_socket != null) {
      return _socket!.future;
    }

    final completer = _socket = Completer<Socket>();

    Socket.connect(connectParams.host, connectParams.port).then(
      (socket) {
        if (_closed) socket.destroy();

        completer.complete(socket);
        _socketSubscription?.cancel();
        _socketSubscription = socket.listen(
          (event) => _readController.add(r.BytesBuffer(event)),
        );
      },
      onError: (Object e, StackTrace st) {
        _socket!.completeError(e, st);
        _socket = null;
      },
    );

    return completer.future;
  }
}
