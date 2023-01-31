import 'dart:convert';

import 'package:crypto/crypto.dart';

List<int> getSha256FromBytes(List<int> bytes) {
  var res = sha256.convert(bytes).bytes;

  return res;
}