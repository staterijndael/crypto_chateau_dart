part of connection;

class MultiplexConnection implements Connection {
  final Connection _connection;

  MultiplexConnection(this._connection);

  @override
  Stream<r.BytesBuffer> get read => _connection.read.map(
        (event) => event..add(const r.MultiplexApplier()),
      );

  @override
  void write(w.BytesBuffer bytes) {
    final requestId = bytes.properties.first as w.RequestId;
    _connection.write(bytes..add(w.Multiplex(requestId.id)));
  }
}
