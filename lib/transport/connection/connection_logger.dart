part of connection;

class ConnectionLogger implements Connection {
  final Connection _connection;

  const ConnectionLogger(this._connection);

  @override
  Stream<Uint8List> get read => _connection.read.doOnData(
        (event) => print('Receive(${DateTime.now()}): $event'),
  );

  @override
  void write(Uint8List bytes) {
    print('Send(${DateTime.now()}): $bytes');
    _connection.write(bytes);
  }
}
