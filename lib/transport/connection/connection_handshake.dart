part of connection;

enum HandshakeStatus {
  none,
  firstRequest,
  secondRequest,
  completed,
}

extension HandshakeStatusX on HandshakeStatus {
  bool get isCompleted => this == HandshakeStatus.completed;

  R when<R>({
    required R Function() none,
    required R Function() firstRequest,
    required R Function() secondRequest,
    required R Function() completed,
  }) {
    switch (this) {
      case HandshakeStatus.none:
        return none();
      case HandshakeStatus.firstRequest:
        return firstRequest();
      case HandshakeStatus.secondRequest:
        return secondRequest();
      case HandshakeStatus.completed:
        return completed();
    }
  }
}

class ConnectionHandshake implements Connection {
  final Connection _connection;
  final Encryption _encryption;
  final _buffer = List<Uint8List>.empty(growable: true);
  var _handshakeStatus = HandshakeStatus.none;
  late Uint8List _publicKey;
  late Uint8List _privateKey;

  ConnectionHandshake(this._connection, this._encryption);

  @override
  Stream<Uint8List> get read {
    final controller = StreamController<Uint8List>(sync: true);
    final subscription = _connection.read.listen(
      (bytes) => _handshakeStatus.when(
        none: () {},
        firstRequest: () {
          _publicKey = bytes;
          _privateKey = _createPrivateKey();
          _handshakeStatus = HandshakeStatus.secondRequest;
          _connection.write(X25519(_privateKey, basePoint));
        },
        secondRequest: () {
          if (bytes.first != 49) {
            controller.addError(const ConnectionHandshakeError(), StackTrace.current);
            _buffer.clear();

            return;
          }

          _encryption.key = X25519(_privateKey, _publicKey);
          print('key: ${_encryption.key}');
          _handshakeStatus = HandshakeStatus.completed;
          _buffer.forEach(write);
          _buffer.clear();
        },
        completed: () => controller.add(bytes),
      ),
      onError: (e, st) {
        if (e is ConnectionErrorFatal) {
          _buffer.clear();
        }

        controller.addError(e, st);
      },
      onDone: controller.close,
    );
    controller
      ..onResume = subscription.resume
      ..onPause = subscription.pause
      ..onCancel = subscription.cancel;

    return controller.stream;
  }

  @override
  void write(Uint8List bytes) {
    switch (_handshakeStatus) {
      case HandshakeStatus.none:
        _buffer.add(bytes);
        _handshakeStatus = HandshakeStatus.firstRequest;
        _connection.write(Uint8List.fromList([104, 97, 110, 100, 115, 104, 97, 107, 101]));
        break;
      case HandshakeStatus.firstRequest:
      case HandshakeStatus.secondRequest:
        return _buffer.add(bytes);
      case HandshakeStatus.completed:
        return _connection.write(bytes);
    }
  }
}

Uint8List _createPrivateKey() {
  var privateKey = Uint8List(32);
  var secureRandom = Random.secure();
  for (var i = 0; i < privateKey.length; i++) {
    privateKey[i] = secureRandom.nextInt(256);
  }

  privateKey[0] &= 248;
  privateKey[31] &= 63;
  privateKey[31] |= 64;

  return privateKey;
}
