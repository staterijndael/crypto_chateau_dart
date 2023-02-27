part of connection;

class ConnectionLogger implements Connection {
  final Connection _connection;
  final String? name;

  const ConnectionLogger(this._connection, [this.name]);

  @override
  Stream<r.BytesBuffer> get read => _connection.read.doOnData(
        (event) => print('${_name}receive(${DateTime.now()}): $event'),
  );

  String get _name => name != null ? '$name-' : '';

  @override
  void write(w.BytesBuffer bytes) {
    print('${_name}send(${DateTime.now()}): $bytes');
    _connection.write(bytes);
  }
}
