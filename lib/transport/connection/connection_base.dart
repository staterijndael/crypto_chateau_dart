import 'dart:async';
import 'package:crypto_chateau_dart/crypto_chateau_dart.dart';
import 'bytes_buffer_write.dart' as w;
import 'bytes_buffer_read.dart' as r;

class ConnectionBase implements Connection {
  final Connection _connection;

  const ConnectionBase(this._connection);

  @override
  Stream<r.BytesBuffer> get read => _connection.read;

  @override
  void write(w.BytesBuffer buffer) => _connection.write(buffer);
}
