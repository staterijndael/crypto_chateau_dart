import 'dart:io';
import 'package:crypto_chateau_dart/client/binary_iterator.dart';
import 'package:crypto_chateau_dart/client/conv.dart';
import 'package:crypto_chateau_dart/client/models.dart';
import 'package:crypto_chateau_dart/transport/conn.dart';
import 'package:crypto_chateau_dart/transport/handler.dart';
import 'package:crypto_chateau_dart/transport/handshake.dart';
import 'package:crypto_chateau_dart/transport/meta.dart';
import 'package:crypto_chateau_dart/transport/pipe.dart';
import 'package:crypto_chateau_dart/version/version.dart';

class Peer {
  final Pipe pipe;

  static const int errByte = 0x2F;
  static const int okByte = 0x20;

  Peer(this.pipe);

  static Peer newPeer(Socket socket) {
    return Peer(Pipe(Conn(socket)));
  }

  Future<void> establishSecureConn() async {
    final securedConnect = await ServerHandshake(pipe.tcpConn);
    pipe.tcpConn = securedConnect;
  }

  Future<void> sendRequestClient(HandlerHash handlerHash, Message msg) async {
    List<int> resp = [];

    resp.add(newProtocolByte());
    resp.addAll(handlerHash.hash);
    resp.addAll(msg.Marshal());

    pipe.write(resp);
  }

  Future<void> writeResponse(Message msg) async {
    List<int> resp = [];

    resp.add(newProtocolByte());
    resp.add(okByte);
    resp.addAll(msg.Marshal());

    pipe.write(resp);
  }

  Future<Message> readMessage(Message msg) async {
    final msgRaw = await pipe.read();

    final serverRespMetaInfo = getServerRespMetaInfo(msgRaw);
    final offset = serverRespMetaInfo.payloadOffset;

    if (msgRaw[offset] == errByte) {
      throw Exception(
          'chateau rpc: status = error, description = ${String.fromCharCodes(msgRaw.sublist(2))}');
    }

    if (offset + 1 + msgRaw.length < objectBytesPrefixLength) {
      throw Exception('not enough for size and message');
    }

    msg.Unmarshal(
        BinaryIterator(msgRaw.sublist(offset + 1 + objectBytesPrefixLength)));

    return msg;
  }

  Future<void> writeError(Object error) async {
    List<int> resp = [];

    resp.add(newProtocolByte());
    resp.add(errByte);
    resp.addAll(error.toString().codeUnits);

    pipe.write(resp);
  }

  Future<void> write(List<int> data) async {
    pipe.write(data);
  }

  Future<List<int>> read() async {
    return await pipe.read();
  }
}
