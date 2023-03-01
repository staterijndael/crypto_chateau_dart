part of connection;

class ConnectionLogger extends ConnectionBase {
  final String? name;

  ConnectionLogger(super._connection, [this.name]);

  String get _name => name != null ? '$name-' : '';

  Stream<r.BytesBuffer> get read => super.read.map(
        (buffer) {
          print('${_name}receive(${DateTime.now()}): $buffer');

          return buffer;
        },
      );

  @override
  void write(w.BytesBuffer buffer) {
    print('${_name}send(${DateTime.now()}): $buffer');
    super.write(buffer);
  }
}
