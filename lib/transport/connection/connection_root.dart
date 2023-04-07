import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto_chateau_dart/crypto_chateau_dart.dart';
import 'bytes_writer.dart';
import 'bytes_reader.dart';

class ConnectParams {
  final String host;
  final int port;
  final bool isEncryptionEnabled;

  const ConnectParams({
    required this.host,
    required this.port,
    required this.isEncryptionEnabled,
  });
}

enum ConnectionState {
  connected,
  disconnected,
}

class ConnectionRoot implements Connection {
  final ConnectParams _connectParams;
  final StreamController<ConnectionState> _stateController;
  final StreamController<BytesReader> _readController;
  late _State _state = _StateNone(this);

  ConnectionRoot(this._connectParams)
      : _stateController = StreamController<ConnectionState>.broadcast(sync: true),
        _readController = StreamController<BytesReader>.broadcast(sync: true);

  Future<void> close() async {
    await _state.close();
    await _readController.close();
    await _stateController.close();
  }

  @override
  Stream<ConnectionState> get connectionState => _stateController.stream;

  @override
  Stream<BytesReader> get read => _readController.stream;

  @override
  void write(BytesWriter buffer) => _state.write(buffer);

  void _addError(Object error, StackTrace? stackTrace) => _readController.addError(error, stackTrace);

  void _setStateNone() {
    _state = _StateNone(this);
    _stateController.add(ConnectionState.disconnected);
  }

  void _setStateInit() => _state = _StateInit(this);

  void _setStateIdle(Socket socket) {
    _state = _StateIdle(this, socket);
    _stateController.add(ConnectionState.connected);
  }
}

abstract class _State {
  Future<void> close();

  void write(BytesWriter buffer);
}

class _StateNone implements _State {
  final ConnectionRoot _context;

  _StateNone(this._context);

  Future<void> close() => Future.value();

  @override
  void write(BytesWriter buffer) {
    _context._setStateInit();
    _context._state.write(buffer);
  }
}

class _StateInit implements _State {
  final ConnectionRoot _context;
  final _buffer = List<BytesWriter>.empty(growable: true);

  _StateInit(this._context) {
    Socket.connect(
      _connectParams.host,
      _connectParams.port,
    ).then(
      (socket) {
        _context._setStateIdle(socket);
        _buffer.forEach(_context._state.write);
        _buffer.clear();
      },
      onError: (Object e, StackTrace st) {
        _context._addError(e, st);
        _context._setStateNone();
      },
    );
  }

  get _connectParams => _context._connectParams;

  Future<void> close() => Future.value();

  @override
  void write(BytesWriter buffer) => _buffer.add(buffer);
}

class _StateIdle implements _State {
  final ConnectionRoot _context;
  final Socket _socket;
  StreamController<BytesWriter>? _writeController;
  StreamSubscription<void>? _writeSubscription;
  StreamSubscription<Uint8List>? _readSubscription;

  _StateIdle(this._context, this._socket) {
    if (_readController.hasListener) {
      _createReadSubscription();
    } else {
      _readController.onListen = _createReadSubscription;
    }
  }

  StreamController<BytesReader> get _readController => _context._readController;

  void _createReadSubscription() {
    if (_readSubscription != null) return;

    _readSubscription = _socket.listen(
      (bytes) => _readController.add(BytesReader(bytes)),
      onError: (e, st) {
        print('DONE');
        _context._addError(e, st);
        _context._setStateNone();
        close().ignore();
      },
      onDone: () {
        print('DONE');
        _context._setStateNone();
        close().ignore();
      },
    );
  }

  Future<void> close() async {
    await _writeController?.close();
    await _writeSubscription?.cancel();
    await _readSubscription?.cancel();
    _socket.destroy();
  }

  @override
  void write(BytesWriter buffer) => _getWriteController().add(buffer);

  StreamController<BytesWriter> _getWriteController() {
    var writeController = _writeController;

    if (writeController != null) return writeController;

    writeController = _writeController = StreamController<BytesWriter>();
    _socket.addStream(writeController.stream.map(_toBytes));

    return writeController;
  }
}

Uint8List _toBytes(BytesWriter buffer) => buffer.toBytes();
