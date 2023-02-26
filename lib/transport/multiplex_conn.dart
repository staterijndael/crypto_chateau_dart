import 'dart:async';
import 'dart:typed_data';
import 'package:crypto_chateau_dart/transport/connection.dart';

class MultiplexConnection implements Connection {
  final MultiplexConnectionPool _pool;
  final int _requestID;
  @override
  Uint8List? encryptionKey;

  MultiplexConnection._(this._pool, this._requestID);

  @override
  Stream<Uint8List> get read =>
      _pool._broadcastConnection.where((event) {
        print('Multi: $event');
        final r = (event[0] & 0xff) | ((event[1] & 0xff) << 8) == _requestID;
        print('Multi: $r');

        return (event[0] & 0xff) | ((event[1] & 0xff) << 8) == _requestID;
      });

  @override
  void write(Uint8List bytes) {
    final fullMessage = Uint8List(bytes.length + 2);
    fullMessage[0] = (_requestID >> 0) & 0xFF;
    fullMessage[1] = (_requestID >> 8) & 0xFF;
    _pool._connection.write(fullMessage..setRange(2, bytes.length, bytes));
  }

  @override
  String toString() => 'MultiplexConn($_requestID)';
}

class MultiplexConnectionPool {
  final Connection _connection;
  final _connectionsByRequestID = <int, MultiplexConnection>{};
  final Stream<Uint8List> _broadcastConnection;
  int _currentRequestID = 0;

  MultiplexConnectionPool(this._connection) : _broadcastConnection = _connection.read.asBroadcastStream();

  int get currentRequestID => _currentRequestID;

  MultiplexConnection newMultiplexConnection() {
    final requestID = ++_currentRequestID;

    return _connectionsByRequestID[requestID] = MultiplexConnection._(this, requestID);
  }
}
