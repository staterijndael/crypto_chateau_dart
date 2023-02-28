part of connection;

class MultiplexConnection extends ConnectionBase {
  MultiplexConnection(super._connection);

  @override
  void _read(r.BytesBuffer buffer) => _controller.add(buffer..add(const r.MultiplexApplier()));

  @override
  void write(w.BytesBuffer buffer) {
    final requestId = buffer.properties.first as w.RequestId;
    super.write(buffer..add(w.Multiplex(requestId.id)));
  }
}
