library connection;

import 'dart:async';
import 'bytes_writer.dart';
import 'bytes_reader.dart';
import 'connection_root.dart';
import 'connection_cipher.dart';
import 'connection_logger.dart';
import 'connection_pipe.dart';
import 'multiplex_connection.dart';
import 'encryption.dart';

export 'connection_base.dart';
export 'connection_root.dart';
export 'connection_cipher.dart';
export 'connection_logger.dart';
export 'connection_pipe.dart';
export 'multiplex_connection.dart';
export 'peer.dart';
export 'error.dart';
export 'encryption.dart';

abstract class Connection {
  static ConnectionRoot root(ConnectParams connectParams) => ConnectionRoot(connectParams);

  factory Connection.cipher(Connection connection, Encryption encryption) = ConnectionCipher;

  factory Connection.pipe(Connection connection) = ConnectionPipe;

  factory Connection.logger(Connection connection, [String? name]) = ConnectionLogger;

  Stream<BytesReader> get read;

  void write(BytesWriter bytes);
}

extension ConnectionX on Connection {
  Connection cipher(Encryption encryption) => Connection.cipher(this, encryption);

  Connection pipe() => Connection.pipe(this);

  Connection logger([String? name]) => Connection.logger(this, name);
}
