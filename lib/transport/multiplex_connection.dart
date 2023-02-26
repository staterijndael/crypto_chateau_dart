import 'dart:async';
import 'dart:typed_data';
import 'package:crypto_chateau_dart/transport/connection/connection.dart';

class MultiplexConnection {
  final Connection _connection;

  MultiplexConnection(this._connection);

  Stream<MultiplexMessage> get read => _connection.read.map(MultiplexMessage.fromBytes);

  void write(MultiplexMessage message) => _connection.write(message.toBytes());
}

class MultiplexMessage {
  final int requestId;
  final Uint8List bytes;

  const MultiplexMessage(this.requestId, this.bytes);

  MultiplexMessage.fromBytes(Uint8List bytes)
      : requestId = (bytes[0] & 0xff) | ((bytes[1] & 0xff) << 8),
        bytes = bytes.sublist(2);

  Uint8List toBytes() {
    final fullBytes = Uint8List(bytes.length + 2);
    fullBytes[0] = (requestId >> 0) & 0xFF;
    fullBytes[1] = (requestId >> 8) & 0xFF;
    fullBytes.setRange(2, bytes.length, bytes);

    return fullBytes;
  }

  @override
  String toString() => 'MultiplexMessage(requestId: $requestId, \nbytes: $bytes)';
}
