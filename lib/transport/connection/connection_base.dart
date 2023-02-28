part of connection;

abstract class ConnectionBase implements Connection {
  final Connection _connection;
  late final StreamController<r.BytesBuffer> _controller;
  bool _listenConnection = false;

  ConnectionBase(this._connection) {
    _controller = StreamController<r.BytesBuffer>(sync: true)..onListen = _startListenConnection;
  }

  @override
  Stream<r.BytesBuffer> get read => _controller.stream;

  @override
  void write(w.BytesBuffer buffer) {
    _startListenConnection();
    _connection.write(buffer);
  }

  void _read(r.BytesBuffer buffer);

  void _startListenConnection() {
    if (_listenConnection) return;

    final subscription = _connection.read.listen(_read);
    _controller
      ..onResume = subscription.resume
      ..onPause = subscription.pause
      ..onCancel = subscription.cancel;
    _listenConnection = true;
  }
}
