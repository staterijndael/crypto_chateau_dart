import 'dart:async';
import 'dart:typed_data';
import 'package:crypto_chateau_dart/crypto_chateau_dart.dart';
import 'package:crypto_chateau_dart/version/version.dart';
import 'package:crypto_chateau_dart/transport/meta.dart';
import 'bytes_writer.dart';

class Peer {
  final _Peer _loop;

  Peer(MultiplexConnection connection) : _loop = _Peer(connection);

  Future<Uint8List> sendRequest(HandlerHash hash, Message request) async {
    final builder = BytesBuilder(copy: false);
    builder.addByte(newProtocolByte());
    builder.add(hash.hash);
    builder.add(request.Marshal());

    return _loop.sendRequest(builder.toBytes());
  }

  Stream<Uint8List> sendStreamRequest(HandlerHash hash, Message request) {
    final builder = BytesBuilder(copy: false);
    builder.addByte(newProtocolByte());
    builder.add(hash.hash);
    builder.add(request.Marshal());

    return _loop.sendStreamRequest(builder.toBytes());
  }
}

class _Peer {
  static const int errByte = 0x2F;
  final MultiplexConnection _connection;

  const _Peer(this._connection);

  Future<Uint8List> sendRequest(Uint8List bytes) async {
    final connection = _createConnection();
    connection.write(BytesWriter()..writeData(bytes));
    final response = await connection.read.first;

    final serverRespMetaInfo = getServerRespMetaInfo(bytes);
    final offset = serverRespMetaInfo.payloadOffset;

    if (response[offset] == errByte) {
      throw MultiplexRequestLoopRPCError(bytes);
    }

    if (offset + 1 + response.length < objectBytesPrefixLength) {
      throw MultiplexRequestLoopSizeError();
    }

    response.readIdle(offset + 1 + objectBytesPrefixLength);

    return response.read();
  }

  Stream<Uint8List> sendStreamRequest(Uint8List bytes) async* {
    final connection = _createConnection();
    connection.write(BytesWriter()..writeData(bytes));

    await for (var response in connection.read) {
      final serverRespMetaInfo = getServerRespMetaInfo(bytes);
      final offset = serverRespMetaInfo.payloadOffset;

      if (response[offset] == errByte) {
        yield* Stream.error(MultiplexRequestLoopRPCError(bytes), StackTrace.current);
        continue;
      }

      if (response.length < objectBytesPrefixLength) {
        yield* Stream.error(MultiplexRequestLoopSizeError(), StackTrace.current);
        continue;
      }

      response.readIdle(objectBytesPrefixLength);

      yield response.read();
    }
  }

  Connection _createConnection() => Connection.pipe(_connection.createConnection());
}

class MultiplexRequestLoopRPCError implements Exception {
  final Uint8List bytes;

  const MultiplexRequestLoopRPCError(this.bytes);

  @override
  String toString() => '$runtimeType: status = error, description = ${String.fromCharCodes(bytes.sublist(2))}';
}

class MultiplexRequestLoopSizeError implements Exception {
  const MultiplexRequestLoopSizeError();

  @override
  String toString() => '$runtimeType: not enough for size and message';
}
