part of connection;

abstract class ConnectionError implements Exception {}

abstract class ConnectionErrorFatal implements ConnectionError {}

class ConnectionHandshakeError implements ConnectionErrorFatal {
  final Uint8List bytes;

  const ConnectionHandshakeError(this.bytes);

  @override
  String toString() => '$runtimeType: expected success handshake message from server, bytes: $bytes';
}

class ConnectionRootError implements ConnectionErrorFatal {
  const ConnectionRootError();

  @override
  String toString() => '$runtimeType: can not connect to server';
}
