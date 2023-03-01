import 'dart:math';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/extensions.dart';
import 'package:crypto_chateau_dart/transport/connection/connection_pipe.dart';
import 'package:crypto_chateau_dart/transport/connection/encryption.dart';
import 'package:crypto_chateau_dart/transport/connection/error.dart';
import 'package:crypto_chateau_dart/transport/utils.dart';
import 'package:x25519/x25519.dart';
import 'connection_base.dart';
import 'bytes_buffer_write.dart' as w;
import 'bytes_buffer_read.dart' as r;

class ConnectionCipher extends ConnectionBase {
  final Encryption _encryption;
  late _State _state;

  ConnectionCipher(super._connection, this._encryption) {
    _state = _encryption.key.when(
      isNull: () => _StateNone(this),
      isNotNull: (_) => _StateIdle(this),
    );
  }

  @override
  Stream<r.BytesBuffer> get read => super.read.asyncExpand((buffer) => _state.read(buffer));

  @override
  void write(w.BytesBuffer buffer) => _state.write(buffer);

  void Function(w.BytesBuffer buffer) get _write => super.write;
}

abstract class _State {
  Stream<r.BytesBuffer> read(r.BytesBuffer event);

  void write(w.BytesBuffer buffer);
}

/// Состояние до начала работы
/// При поступлении запроса начинает процесс рукопожатия
class _StateNone implements _State {
  final ConnectionCipher _context;

  _StateNone(this._context);

  @override
  Stream<r.BytesBuffer> read(r.BytesBuffer event) => Stream.empty();

  @override
  void write(w.BytesBuffer buffer) => _context._state = _StateInProgress(_context)..write(buffer);
}

/// Оборачивает шаги рукапожатия в Pipe
/// Кеширует все запросы клиента в буффер до завершения рукопожатия
class _StateInProgress implements _State {
  final ConnectionCipher _context;
  late _StateInProgressState _state;
  final _buffer = List<w.BytesBuffer>.empty(growable: true);
  final _pipe = Pipe();

  _StateInProgress(this._context) {
    _state = _StateInProgressStateFirstRequest(this);
  }

  /// Преобразует байты через Pipe, затем оборачивает StreamSink
  /// в _RedirectSink, чтоб перенаправить вызов чтения Pipe в [_state]
  @override
  Stream<r.BytesBuffer> read(r.BytesBuffer buffer) => _pipe.read(buffer).asyncExpand((buffer) => _state.read(buffer));

  @override
  void write(w.BytesBuffer buffer) => _buffer.add(buffer);

  /// Метод отправки данных для состояний (обёрнут в Pipe)
  void _write(w.BytesBuffer buffer) {
    _pipe.write(buffer);
    _context._write(buffer);
  }

  void _toIdle(Uint8List encryptionKey) {
    _context._encryption.key = encryptionKey;
    final newState = _context._state = _StateIdle(_context);
    _buffer.forEach(newState.write);
    _buffer.clear();
  }
}

class _StateIdle implements _State {
  final ConnectionCipher _context;

  _StateIdle(this._context);

  @override
  Stream<r.BytesBuffer> read(r.BytesBuffer buffer) => Stream.value(_decrypt(buffer));

  @override
  void write(w.BytesBuffer buffer) => _context._write(_encrypt(buffer));

  Encryption get _encryption => _context._encryption;

  r.BytesBuffer _decrypt(r.BytesBuffer buffer) => _encryption.key.when(
        isNull: () => buffer,
        isNotNull: (sharedKey) => buffer..add(r.DecryptApplier(sharedKey)),
      );

  w.BytesBuffer _encrypt(w.BytesBuffer buffer) => _encryption.key.when(
        isNull: () => buffer,
        isNotNull: (sharedKey) => buffer..add(w.Encrypt(sharedKey)),
      );
}

abstract class _StateInProgressState {
  Stream<r.BytesBuffer> read(r.BytesBuffer buffer);
}

/// При создании отправляет на сервер первый ключ для рукопожатия
/// Ждёт в ответ публичный ключ
class _StateInProgressStateFirstRequest implements _StateInProgressState {
  final _StateInProgress _context;

  _StateInProgressStateFirstRequest(this._context) {
    final key = Uint8List.fromList([104, 97, 110, 100, 115, 104, 97, 107, 101]);
    _context._write(w.BytesBuffer()..add(w.Data(key)));
  }

  @override
  Stream<r.BytesBuffer> read(r.BytesBuffer buffer) async* {
    final publicKey = buffer.bytes;
    final privateKey = _createPrivateKey();
    _context._state = _StateInProgressStateSecondRequest(_context, privateKey, publicKey);
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
}

/// При создании отправляет на сервер второй ключ для рукопожатия
/// Ждёт в ответ сообщение с подтверждением рукопожатия
class _StateInProgressStateSecondRequest implements _StateInProgressState {
  final _StateInProgress _context;
  final Uint8List _publicKey;
  final Uint8List _privateKey;

  _StateInProgressStateSecondRequest(this._context, this._privateKey, this._publicKey) {
    final data = w.Data(X25519(_privateKey, basePoint));
    _context._write(w.BytesBuffer()..add(data));
  }

  @override
  Stream<r.BytesBuffer> read(r.BytesBuffer buffer) async* {
    if (buffer.bytes.first != 49) {
      throw ConnectionHandshakeError(buffer.bytes);
    }

    final encryptionKey = Uint8List.fromList(getSha256FromBytes(X25519(_privateKey, _publicKey)));
    _context._toIdle(encryptionKey);
  }
}
