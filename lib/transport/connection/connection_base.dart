import 'dart:async';
import 'package:crypto_chateau_dart/crypto_chateau_dart.dart';
import 'bytes_writer.dart';
import 'bytes_reader.dart';

class ConnectionBase implements Connection {
  final Connection _connection;

  const ConnectionBase(this._connection);

  @override
  Stream<BytesReader> get read => _connection.read;

  @override
  void write(BytesWriter buffer) => _connection.write(buffer);
}
