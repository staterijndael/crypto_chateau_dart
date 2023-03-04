import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto_chateau_dart/crypto_chateau_dart.dart';
import 'bytes_buffer_write.dart' as w;
import 'bytes_buffer_read.dart' as r;

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
  final ConnectParams connectParams;
  final _readController = StreamController<r.BytesBuffer>(sync: true);
  late _State _state = _StateNone(this);

  ConnectionRoot(this._connectParams);

  Future<void> close() async {
    await _state.close();
    await _readController.close();
  }

  @override
  Stream<r.BytesBuffer> get read => _readController.stream;

  @override
  void write(w.BytesBuffer buffer) => _state.write(buffer);
}

abstract class _State {
  Future<void> close();

  void write(w.BytesBuffer buffer);
}

class _StateNone implements _State {
  final ConnectionRoot _context;

  _StateNone(this._context);

  Future<void> close() => Future.value();

  @override
  void write(w.BytesBuffer buffer) => _context._state = _StateInit(_context)..write(buffer);
}

class _StateInit implements _State {
  final ConnectionRoot _context;
  final _buffer = List<w.BytesBuffer>.empty(growable: true);

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
  void write(w.BytesBuffer buffer) => _buffer.add(buffer);
}

class _StateIdle implements _State {
  final ConnectionRoot _context;
  final Socket _socket;
  StreamController<w.BytesBuffer>? _writeController;
  StreamSubscription<void>? _writeSubscription;
  StreamSubscription<Uint8List>? _readSubscription;

  _StateIdle(this._context, this._socket) {
    if (_readController.hasListener) {
      _createReadSubscription();
    } else {
      _readController.onListen = _createReadSubscription;
    }
  }

  StreamController<r.BytesBuffer> get _readController => _context._readController;

  void _createReadSubscription() {
    if (_readSubscription != null) return;

    _readSubscription = _socket.listen(
          (bytes) => _readController.add(r.BytesBuffer(bytes)),
    );
  }

  Future<void> close() async {
    await _writeController?.close();
    await _writeSubscription?.cancel();
    await _readSubscription?.cancel();
  }

  @override
  void write(w.BytesBuffer buffer) => _getWriteController().add(buffer);

  StreamController<w.BytesBuffer> _getWriteController() {
    var writeController = _writeController;

    if (writeController != null) return writeController;

    writeController = _writeController = StreamController<w.BytesBuffer>();
    _writeSubscription = writeController.stream.asyncMap(_handleWrite).listen(null);

    return writeController;
  }

  Future<void> _handleWrite(w.BytesBuffer buffer) async {
    final bytes = buffer.toBytes();
    _socket.add(Uint8List.fromList([i++]));
    // final watch = Stopwatch()..start();
    // await _socket.flush();
    // watch.stop();
    print(i);
    // await Future.delayed(const Duration(milliseconds: 5));
  }
}

/*
class _StateIdle implements _State {
  final ConnectionRoot _context;
  final Socket _socket;
  StreamController<w.BytesBuffer>? _writeController;
  StreamSubscription<Uint8List>? _readSubscription;

  _StateIdle(this._context, this._socket) {
    if (_readController.hasListener) {
      _createReadSubscription();
    } else {
      _readController.onListen = _createReadSubscription;
    }
  }

  StreamController<r.BytesBuffer> get _readController => _context._readController;

  void _createReadSubscription() {
    _readSubscription = _socket.listen(
          (bytes) => _readController.add(r.BytesBuffer(bytes)),
    );
  }

  Future<void> close() async {
    await _writeController?.close();
    await _readSubscription?.cancel();
  }

  @override
  void write(w.BytesBuffer buffer) => _getWriteController().add(buffer);

  StreamController<w.BytesBuffer> _getWriteController() {
    var writeController = _writeController;

    if (writeController != null) return writeController;

    writeController = _writeController = StreamController<w.BytesBuffer>();
    _socket.addStream(writeController.stream.asyncMap(_handleWrite));

    return writeController;
  }

  Future<Uint8List> _handleWrite(w.BytesBuffer buffer) async {
    final bytes = buffer.toBytes();
    // await Future.delayed(const Duration(milliseconds: 6));

    return bytes;
  }
}
 */
