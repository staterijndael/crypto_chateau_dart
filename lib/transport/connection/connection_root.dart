part of connection;

class ConnectionRoot implements Connection {
  final ConnectParams connectParams;
  late final _controller = StreamController<Uint8List>(sync: true);
  StreamSubscription<Uint8List>? _subscription;
  Completer<Socket>? _socket;
  var _closed = false;

  ConnectionRoot(this.connectParams);

  Future<void> close() async {
    if (_closed) return;

    _closed = true;
    await _subscription?.cancel();
    await _controller.close();
    (await _socket?.future)?.destroy();
  }

  @override
  Stream<Uint8List> get read => _controller.stream;

  @override
  void write(Uint8List bytes) => _initSocket().then(
        (socket) => socket.add(bytes),
        onError: _controller.addError,
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
        _subscription?.cancel();
        _subscription = socket.listen(_controller.add);
      },
      onError: (Object e, StackTrace st) {
        _socket!.completeError(e, st);
        _socket = null;
      },
    );

    return completer.future;
  }
}