part of connection;

class ConnectionBase implements Connection {
  final Connection _connection;

  const ConnectionBase(this._connection);

  @override
  Stream<r.BytesBuffer> get read => _connection.read;

  @override
  void write(w.BytesBuffer buffer) => _connection.write(buffer);
}
