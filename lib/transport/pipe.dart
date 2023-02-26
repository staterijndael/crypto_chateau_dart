import 'dart:typed_data';

import 'package:crypto_chateau_dart/transport/connection/connection.dart';
import 'package:crypto_chateau_dart/transport/socket_packager.dart';

class Pipe implements Connection {
  final Connection _connection;

  const Pipe(this._connection);

  @override
  Stream<Uint8List> get read => _connection.read.pack();

  @override
  void write(Uint8List bytes) async {
    var dataWithLength = Uint8List(bytes.length + 2);
    var convertedLength = bytes.length;
    dataWithLength[0] = convertedLength & 0xff;
    dataWithLength[1] = (convertedLength & 0xff00) >> 8;
    dataWithLength.setRange(2, dataWithLength.length, bytes);
    _connection.write(dataWithLength);
  }
}
