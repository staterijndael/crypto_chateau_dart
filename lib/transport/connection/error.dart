import 'dart:typed_data';

abstract class ConnectionError implements Exception {}

abstract class ConnectionErrorFatal implements ConnectionError {}

class ConnectionHandshakeError implements ConnectionErrorFatal {
  final Uint8List bytes;

  const ConnectionHandshakeError(this.bytes);

  @override
  String toString() => '$runtimeType: expected success handshake message from server, bytes: $bytes';
}

class SocketDoneException {
  const SocketDoneException();

  @override
  String toString() => '$runtimeType: socket is done';
}
