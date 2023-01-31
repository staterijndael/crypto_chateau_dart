import 'dart:convert';

import 'package:crypto/crypto.dart';

class HandlerHash {
  List<int> hash;
  HandlerHash({required this.hash});

  String code() {
    return "hash.HandlerHash{0x${hash[0].toRadixString(16)}, 0x${hash[1].toRadixString(16)}, 0x${hash[2].toRadixString(16)}, 0x${hash[3].toRadixString(16)}}";
  }
}

List<int> getHandlerHash(String serviceName, String handlerName) {
  var hash = sha256.convert(utf8.encode("$serviceName/$handlerName")).bytes;

  return [hash[0], hash[1], hash[2], hash[3]];
}
