import 'dart:math';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/transport/connection.dart';

import 'package:x25519/x25519.dart';

Future<void> serverHandshake(Connection connection) async {
  connection.write(Uint8List.fromList([104, 97, 110, 100, 115, 104, 97, 107, 101]));

  var publicKey = await connection.read.first;
  var privateKey = Uint8List(32);
  var secureRandom = Random.secure();
  for (var i = 0; i < privateKey.length; i++) {
    privateKey[i] = secureRandom.nextInt(256);
  }

  privateKey[0] &= 248;
  privateKey[31] &= 63;
  privateKey[31] |= 64;

  var pub = Uint8List(32);

  pub = X25519(privateKey, basePoint);

  connection.write(pub);
  var msg = await connection.read.first;

  if (msg[0] != 49) {
    throw "expected success handshake message from server";
  }

  connection.encryptionKey = X25519(privateKey, publicKey);
}
