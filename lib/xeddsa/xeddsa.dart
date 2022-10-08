import 'dart:typed_data';

import 'package:crypto_chateau_dart/xeddsa/curve.dart';
import 'package:crypto_chateau_dart/xeddsa/ed25519.dart';

bool verifySignature(
    Uint8List? signingKey, Uint8List? message, Uint8List? signature) {
  if (signingKey == null || message == null || signature == null) {
    throw 'Values must not be null';
  }

  if (signature.length != 64) {
    return false;
  }

  return verifySig(signingKey, message, signature);
}

Uint8List calculateSignature(Uint8List? signingKey, Uint8List? message) {
  if (signingKey == null || message == null) {
    throw Exception('Values must not be null');
  }

  final random = generateRandomBytes();

  return sign(signingKey, message, random);
}
