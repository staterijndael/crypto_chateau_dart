part of connection;

class MultiplexConnection extends ConnectionBase {
  MultiplexConnection(super._connection);

  Stream<r.BytesBuffer> get read => super.read.map(
        (buffer) => buffer..add(const r.MultiplexApplier()),
      );

  @override
  void write(w.BytesBuffer buffer) {
    final requestId = buffer.properties.first as w.RequestId;
    super.write(buffer..add(w.Multiplex(requestId.id)));
  }
}
