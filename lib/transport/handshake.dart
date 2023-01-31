import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/transport/conn.dart';
import 'package:crypto_chateau_dart/transport/pipe.dart';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/src/registry/registry.dart';
import 'package:x25519/x25519.dart';

ServerHandshake(Conn conn) async {
  var pipe = Pipe(conn);

  pipe.write(Uint8List.fromList([104, 97, 110, 100, 115, 104, 97, 107, 101]));

  var connPublicKey = await readConnPubKey(pipe);

  var priv = Uint8List(32);
  var secureRandom = Random.secure();
  for (var i = 0; i < priv.length; i++) {
    priv[i] = secureRandom.nextInt(256);
  }

  priv[0] &= 248;
  priv[31] &= 63;
  priv[31] |= 64;

  var pub = Uint8List(32);

  pub = X25519(priv, basePoint);

  pipe.write(pub);
  var msg = await pipe.read(bufSize: 1);
  if (msg[0] != 49) {
    throw "expected success handshake message from server";
  }

  var sharedKey = X25519(priv, connPublicKey);

  conn.enableEncryption(sharedKey);

  return conn;
}

Future<Uint8List> readConnPubKey(Pipe pipe) async {
  var msg = await pipe.read(bufSize: 32);
  return Uint8List.fromList(msg);
}
