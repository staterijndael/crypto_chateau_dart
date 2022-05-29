import 'dart:math';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/dh/params.dart';

class KeyStore {
  BigInt privateKey = BigInt.from(0);
  BigInt publicKey = BigInt.from(0);
  BigInt sharedKey = BigInt.from(0);

  GenerateSharedKey({required BigInt receivedPublicKey}) {
    if (receivedPublicKey == BigInt.from(0)) {
      throw "invalid received public key";
    }
    if (privateKey == BigInt.from(0)) {
      throw "invalid private key";
    }

    sharedKey = receivedPublicKey.modPow(privateKey, Prime);
  }

  GeneratePublicKey() {
    if (privateKey == BigInt.from(0)) {
      throw "invalid private key";
    }

    publicKey = Generator.modPow(privateKey, Prime);
  }

  GeneratePrivateKey() {
    Random random = Random(DateTime.now().millisecondsSinceEpoch);
    final numBytes = (Prime.bitLength / 8).ceil();

    final builder = BytesBuilder();

    for (var i = 0; i < numBytes; ++i) {
      builder.addByte(random.nextInt(256));
    }

    privateKey = byteArrayToBigInt(builder.toBytes());
  }
}
