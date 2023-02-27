part of connection;

class ConnectionPipe implements Connection {
  final Connection _connection;

  const ConnectionPipe(this._connection);

  @override
  Stream<r.BytesBuffer> get read => _connection.read.map(
        (event) => event..add(const r.LengthApplier()),
      );

  @override
  void write(w.BytesBuffer bytes) => _connection.write(bytes..add(const w.Length()));
}
