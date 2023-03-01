library connection;

import 'dart:async';
import 'bytes_buffer_write.dart' as w;
import 'bytes_buffer_read.dart' as r;
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
export 'multiplex_request_loop.dart';
export 'error.dart';
export 'encryption.dart';

abstract class Connection {
  static ConnectionRoot root(ConnectParams connectParams) => ConnectionRoot(connectParams);

  factory Connection.cipher(Connection connection, Encryption encryption) = ConnectionCipher;

  factory Connection.pipe(Connection connection) = ConnectionPipe;

  factory Connection.multiplex(Connection connection) = MultiplexConnection;

  factory Connection.logger(Connection connection, [String? name]) = ConnectionLogger;

  Stream<r.BytesBuffer> get read;

  void write(w.BytesBuffer bytes);
}

extension ConnectionX on Connection {
  Connection cipher(Encryption encryption) => Connection.cipher(this, encryption);

  Connection pipe() => Connection.pipe(this);

  Connection multiplex() => Connection.multiplex(this);

  Connection logger([String? name]) => Connection.logger(this, name);
}
