import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:crypto_chateau_dart/aes_256/aes_256.dart';

void main() {
  String data = "Дарова";

  List<int> hash = sha256.convert(List.from(<num>[1])).bytes;

  try {
    Uint8List encryptedData = Encrypt(
        Uint8List.fromList(utf8.encode(data)), Uint8List.fromList(hash));

    print(encryptedData);
  } catch (e) {
    print(e);
  }
}
