library connection;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/extensions.dart';
import 'package:crypto_chateau_dart/gen_definitions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:x25519/x25519.dart';
import 'package:crypto_chateau_dart/client/conv.dart';
import 'package:crypto_chateau_dart/transport/handler.dart';
import 'package:crypto_chateau_dart/transport/meta.dart';

import 'bytes_buffer_write.dart' as w;
import 'bytes_buffer_read.dart' as r;

part 'connection_root.dart';
part 'connection_cipher.dart';
part 'connection_handshake.dart';
part 'connection_logger.dart';
part 'encryption.dart';
part 'error.dart';
part 'pipe.dart';
part 'multiplex_connection.dart';
part 'multiplex_request_loop.dart';

abstract class Connection {
  static ConnectionRoot root(ConnectParams connectParams) => ConnectionRoot(connectParams);

  factory Connection.cipher(Connection connection, Encryption encryption) = ConnectionCipher;

  factory Connection.handshake(Connection connection, Encryption encryption) = ConnectionHandshake;

  factory Connection.pipe(Connection connection) = ConnectionPipe;

  factory Connection.multiplex(Connection connection) = MultiplexConnection;

  factory Connection.logger(Connection connection) = ConnectionLogger;

  Stream<r.BytesBuffer> get read;

  void write(w.BytesBuffer bytes);
}
