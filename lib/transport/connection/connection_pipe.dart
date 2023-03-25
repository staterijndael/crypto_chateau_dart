import 'dart:async';
import 'dart:typed_data';
import 'package:crypto_chateau_dart/crypto_chateau_dart.dart';
import 'bytes_writer.dart';
import 'bytes_reader.dart';
import 'package:crypto_chateau_dart/transport/connection/connection_base.dart';

class ConnectionPipe extends ConnectionBase {
  final _pipe = Pipe();

  ConnectionPipe(super._connection);

  @override
  Stream<BytesReader> get read => super.read.asyncExpand(_pipe.read);

  @override
  void write(BytesWriter buffer) {
    _pipe.write(buffer);
    super.write(buffer);
  }
}

class Pipe {
  _BytesReaderWithLength? _reserved;

  Pipe();

  Stream<BytesReader> read(BytesReader buffer) async* {
    var current = _reserved ?? _BytesReaderWithLength(buffer.readLength());

    while (true) {
      final lengthNeed = current.length - current.builder.length;

      if (buffer.length > lengthNeed) {
        current.builder.add(buffer.read(lengthNeed));
        final bytes = current.builder.takeBytes();
        yield BytesReader(bytes);
        current = _reserved ?? _BytesReaderWithLength(buffer.readLength());
        continue;
      }

      current.builder.add(buffer.read());

      if (current.builder.length == current.length) {
        final bytes = current.builder.takeBytes();
        yield BytesReader(bytes);
        break;
      }

      if (buffer.length == 0) {
        break;
      }
    }
  }

  BytesWriter write(BytesWriter buffer) => buffer..writeLength();
}

class _BytesReaderWithLength {
  final builder = BytesBuilder(copy: false);
  final int length;

  _BytesReaderWithLength(this.length);
}
