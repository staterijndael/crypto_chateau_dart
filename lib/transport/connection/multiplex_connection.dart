import 'dart:async';
import 'package:crypto_chateau_dart/transport/connection/connection.dart';
import 'package:crypto_chateau_dart/transport/connection/connection_controller.dart';

import 'bytes_writer.dart';
import 'bytes_reader.dart';

const _lastIdMin = 0;
const _lastIdMax = 0;

class MultiplexConnection {
  final Connection _connection;
  final _connections = <int, ConnectionController>{};
  StreamSubscription<BytesReader>? _subscription;
  int _lastId = _lastIdMin;

  MultiplexConnection(this._connection);

  void _startListenConnection() {
    if (_subscription != null) return;

    _subscription = _connection.read.listen(
      (event) {
        final id = event.readMultiplex();
        _connections[id]?.add(event);
      },
      onDone: () => _connections.values.forEach((e) => e.close()),
    );
  }

  void _cancelListenConnection() {
    _subscription?.cancel();
    _subscription = null;
  }

  Connection createConnection() {
    final id = _getFreeId();

    return _connections[id] = ConnectionController(
      connectionState: _connection.connectionState,
      onWrite: (buffer) => _onWrite(buffer, id),
      onListen: _startListenConnection,
      onCancel: () {
        _connections.remove(id);

        if (_connections.isEmpty) {
          _cancelListenConnection();
        }
      },
    );
  }

  int _getFreeId() {
    do {
      _lastId++;

      if (_lastId == _lastIdMax) {
        _lastId = _lastIdMin;
      }
    } while (_connections.containsKey(_lastId));

    return _lastId;
  }

  void _onWrite(BytesWriter buffer, int id) => _connection.write(buffer..writeMultiplex(id));
}
