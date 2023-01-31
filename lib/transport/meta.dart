import 'package:crypto_chateau_dart/transport/handler.dart';

class GetClientReqMetaInfoRes {
  List<int> protocol;
  HandlerHash handlerKey;
  int payloadOffset;

  GetClientReqMetaInfoRes(
      {required this.protocol,
      required this.handlerKey,
      required this.payloadOffset});
}

GetClientReqMetaInfoRes getClientReqMetaInfo(List<int> p) {
  if (p.length < 6) {
    throw Exception("invalid payload: too short");
  }

  List<int> protocol = p.sublist(0, 1);
  List<int> handlerBytes = p.sublist(1, 5);
  List<int> handlerKey = handlerBytes;

  return GetClientReqMetaInfoRes(
      protocol: protocol,
      handlerKey: HandlerHash(hash: handlerKey),
      payloadOffset: 5);
}

class GetServerRespMetaInfoRes {
  List<int> protocol;
  int payloadOffset;

  GetServerRespMetaInfoRes(
      {required this.protocol, required this.payloadOffset});
}

GetServerRespMetaInfoRes getServerRespMetaInfo(List<int> p) {
  if (p.isEmpty) {
    throw Exception("invalid payload: too short");
  }

  List<int> protocol = p.sublist(0, 1);

  return GetServerRespMetaInfoRes(protocol: protocol, payloadOffset: 1);
}
