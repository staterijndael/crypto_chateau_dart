import 'dart:async';
import 'package:crypto_chateau_dart/crypto_chateau_dart.dart';
import 'bytes_buffer_write.dart' as w;
import 'bytes_buffer_read.dart' as r;
import 'connection_base.dart';

class ConnectionPipe extends ConnectionBase {
  final _pipe = Pipe();

  ConnectionPipe(super._connection);

  @override
  Stream<r.BytesBuffer> get read => super.read.asyncExpand(_pipe.read);

  @override
  void write(w.BytesBuffer buffer) {
    _pipe.write(buffer);
    super.write(buffer);
  }
}

class Pipe {
  r.BytesBuffer? _reserved;

  Pipe();

  Stream<r.BytesBuffer> read(r.BytesBuffer buffer) async* {
    final r.BytesBuffer current;
    final r.Length length;

    if (_reserved != null) {
      current = _reserved!..merge(buffer);
      length = current.properties.first as r.Length;
    } else {
      current = buffer;
      length = current.add(const r.LengthApplier());
    }

    if (buffer.length == length.length) {
      yield buffer;
      _reserved = null;
    }
  }

  w.BytesBuffer write(w.BytesBuffer buffer) => buffer..add(const w.Length());
}
