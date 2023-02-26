library connection;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/extensions.dart';
import 'package:crypto_chateau_dart/aes_256/aes_256.dart';
import 'package:crypto_chateau_dart/gen_definitions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:x25519/x25519.dart';

part 'connection_root.dart';
part 'connection_cipher.dart';
part 'connection_handshake.dart';
part 'connection_logger.dart';
part 'encryption.dart';
part 'error.dart';

abstract class Connection {
  static ConnectionRoot root(ConnectParams connectParams) => ConnectionRoot(connectParams);

  factory Connection.cipher(Connection connection, Encryption encryption) = ConnectionCipher;

  factory Connection.handshake(Connection connection, Encryption encryption) = ConnectionHandshake;

  factory Connection.logger(Connection connection) = ConnectionLogger;

  Stream<Uint8List> get read;

  void write(Uint8List bytes);
}
