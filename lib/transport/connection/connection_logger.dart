part of connection;

class ConnectionLogger implements Connection {
  final Connection _connection;

  const ConnectionLogger(this._connection);

  @override
  Stream<r.BytesBuffer> get read => _connection.read.doOnData(
        (event) => print('Receive(${DateTime.now()}): $event'),
  );

  @override
  void write(w.BytesBuffer bytes) {
    print('Send(${DateTime.now()}): $bytes');
    _connection.write(bytes);
  }
}
