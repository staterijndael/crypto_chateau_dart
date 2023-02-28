part of connection;

class ConnectionLogger extends ConnectionBase {
  final String? name;

  ConnectionLogger(super._connection, [this.name]);

  String get _name => name != null ? '$name-' : '';

  @override
  void _read(r.BytesBuffer buffer) {
    print('${_name}receive(${DateTime.now()}): $buffer');
    _controller.add(buffer);
  }

  @override
  void write(w.BytesBuffer buffer) {
    print('${_name}send(${DateTime.now()}): $buffer');
    _connection.write(buffer);
  }
}
