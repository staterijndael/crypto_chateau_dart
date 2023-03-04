import 'dart:async';
import 'bytes_writer.dart';
import 'bytes_reader.dart';
import 'package:crypto_chateau_dart/transport/connection/connection_base.dart';

class ConnectionLogger extends ConnectionBase {
  final String? name;

  ConnectionLogger(super._connection, [this.name]);

  String get _name => name != null ? '$name-' : '';

  Stream<BytesReader> get read => super.read.map(
        (buffer) {
          print('${_name}receive(${DateTime.now()}): $buffer');

          return buffer;
        },
      );

  @override
  void write(BytesWriter buffer) {
    print('${_name}send(${DateTime.now()}): $buffer');
    super.write(buffer);
  }
}
