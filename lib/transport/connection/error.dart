part of connection;

abstract class ConnectionError implements Exception {}

abstract class ConnectionErrorFatal implements ConnectionError {}

class ConnectionHandshakeError implements ConnectionErrorFatal {
  const ConnectionHandshakeError();

  @override
  String toString() => '$runtimeType: expected success handshake message from server';
}

class ConnectionRootError implements ConnectionErrorFatal {
  const ConnectionRootError();

  @override
  String toString() => '$runtimeType: can not connect to server';
}
