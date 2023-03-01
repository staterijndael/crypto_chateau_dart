part of connection;

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
  StreamSubscription<Uint8List>? _socketSubscription;
  Completer<Socket>? _socket;
  var _closed = false;

  ConnectionRoot(this.connectParams);

  Future<void> close() async {
    if (_closed) return;

    _closed = true;
    await _socketSubscription?.cancel();
    await _readController.close();
    (await _socket?.future)?.destroy();
  }

  @override
  Stream<r.BytesBuffer> get read => _readController.stream;

  @override
  void write(w.BytesBuffer bytes) => _initSocket().then(
        (socket) => socket.add(bytes.toBytes()),
        onError: _readController.addError,
      );

  Future<Socket> _initSocket() {
    if (_socket != null) {
      return _socket!.future;
    }

    final completer = _socket = Completer<Socket>();

    Socket.connect(connectParams.host, connectParams.port).then(
      (socket) {
        if (_closed) socket.destroy();
        socket.flush();

        completer.complete(socket);
        _socketSubscription?.cancel();
        _socketSubscription = socket.listen(
          (event) => _readController.add(r.BytesBuffer(event)),
        );
      },
      onError: (Object e, StackTrace st) {
        _socket!.completeError(e, st);
        _socket = null;
      },
    );

    return completer.future;
  }
}

// abstract class _State {
//   void write(w.BytesBuffer buffer);
// }
//
// class _StateNone implements _State {
//   final ConnectionCipher _context;
//
//   _StateNone(this._context);
//
//   @override
//   void write(w.BytesBuffer buffer) {
//
//     _context._state = _StateInProgress(_context)..write(buffer);
//   }
// }
//
// class _StateInProgress implements _State {
//   final ConnectionCipher _context;
//   late _StateInProgressState _state;
//   final _buffer = List<w.BytesBuffer>.empty(growable: true);
//   late final Pipe _pipe;
//
//   _StateInProgress(this._context) {
//     _pipe = Pipe(
//       onRead: (buffer) => _state.read(buffer),
//       onWrite: _context._connection.write,
//     );
//     _state = _StateInProgressStateFirstRequest(this);
//   }
//
//   @override
//   void read(r.BytesBuffer buffer) => _pipe.read(buffer);
//
//   @override
//   void write(w.BytesBuffer buffer) => _buffer.add(buffer);
//
//   /// метод отправки данных для состояний (обёрнут в Pipe)
//   void _write(w.BytesBuffer buffer) => _pipe.write(buffer);
//
//   void _toIdle(Uint8List encryptionKey) {
//     _context._encryption.key = encryptionKey;
//     final newState = _context._state = _StateIdle(_context);
//     _buffer.forEach(newState.write);
//     _buffer.clear();
//   }
// }
