import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/aes_256/aes_256.dart';
import 'package:crypto_chateau_dart/transport/message.dart';

abstract class Connection {
  factory Connection(Socket socket, [Uint8List? encryptionKey]) = ConnectionImpl;

  abstract Uint8List? encryptionKey;

  Stream<Uint8List> get read;

  void write(Uint8List bytes);
}

class ConnectionImpl implements Connection {
  final Socket _socket;
  @override
  Uint8List? encryptionKey;

  ConnectionImpl(this._socket, [this.encryptionKey]);

  @override
  Stream<Uint8List> get read => _socket.map(
        (bytes) {
          print('Receive: $bytes');

          return encryptionKey.when(
            isNull: () => bytes,
            isNotNull: (sharedKey) => Decrypt(bytes, sharedKey),
          );
        },
      ).pack();

  @override
  void write(Uint8List bytes) {
    encryptionKey.mayBeWhen(
      isNotNull: (sharedKey) => bytes = Encrypt(bytes, sharedKey),
    );
    var dataWithLength = Uint8List(bytes.length + 2);
    var convertedLength = bytes.length;
    dataWithLength[0] = convertedLength & 0xff;
    dataWithLength[1] = (convertedLength & 0xff00) >> 8;
    dataWithLength.setRange(2, dataWithLength.length, bytes);
    print('Send: $bytes');
    _socket.add(bytes);
  }
}

extension NullableObjectX<T extends Object> on T? {
  R when<R>({
    required R Function() isNull,
    required R Function(T object) isNotNull,
  }) =>
      this == null ? isNull() : isNotNull(this!);

  R? mayBeWhen<R>({
    R Function()? isNull,
    R Function(T object)? isNotNull,
  }) =>
      this == null ? isNull?.call() : isNotNull?.call(this!);
}


