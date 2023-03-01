import 'dart:async';
import 'package:crypto_chateau_dart/crypto_chateau_dart.dart';
import 'bytes_buffer_write.dart' as w;
import 'bytes_buffer_read.dart' as r;
import 'connection_base.dart';

class MultiplexConnection extends ConnectionBase {
  MultiplexConnection(super._connection);

  Stream<r.BytesBuffer> get read => super.read.map(
        (buffer) => buffer..add(const r.MultiplexApplier()),
      );

  @override
  void write(w.BytesBuffer buffer) {
    final requestId = buffer.properties.first as w.RequestId;
    super.write(buffer..add(w.Multiplex(requestId.id)));
  }
}
