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

class ConnectionRoot implements Connection {
  final ConnectParams _connectParams;
  final _readController = StreamController<BytesReader>.broadcast(sync: true);
  late _State _state = _StateNone(this);

  ConnectionRoot(this._connectParams);

  Future<void> close() async {
    await _state.close();
    await _readController.close();
  }

  @override
  Stream<BytesReader> get read => _readController.stream;

  @override
  void write(BytesWriter buffer) => _state.write(buffer);
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
  void write(BytesWriter buffer) =>
      _context._state = _StateInit(_context)
        ..write(buffer);
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
        final state = _context._state = _StateIdle(_context, socket);
        _buffer.forEach(state.write);
      },
      onError: (Object e, StackTrace st) {
        _context._readController.addError(e, st);

        /// TODO: ретраи, фатальные ошибки
      },
    );
  }

  ConnectParams get _connectParams => _context._connectParams;

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
    );
  }

  Future<void> close() async {
    await _writeController?.close();
    await _writeSubscription?.cancel();
    await _readSubscription?.cancel();
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
