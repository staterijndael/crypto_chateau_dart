import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/client/models.dart';

int ConvertBytesToInt8(Uint8List b) {
  return b[0];
}

int ConvertBytesToInt32(Uint8List b) {
  return b[3] | b[2] << 8 | b[1] << 16 | b[0] << 24;
}

int ConvertBytesToInt64(Uint8List b) {
  return b[7] |
      b[6] << 8 |
      b[5] << 16 |
      b[4] << 24 |
      b[3] << 32 |
      b[2] << 40 |
      b[1] << 48 |
      b[0] << 56;
}

Uint8List ConvertInt8ToBytes(int num) {
  return Uint8List.fromList([num]);
}

Uint8List ConvertInt32ToBytes(int num) {
  Uint8List buf = Uint8List(4);
  buf[0] = num >> 24;
  buf[1] = num >> 16;
  buf[2] = num >> 8;
  buf[3] = num;

  return buf;
}

Uint8List ConvertInt64ToBytes(int num) {
  Uint8List buf = Uint8List(8);
  buf[0] = num >> 56;
  buf[1] = num >> 48;
  buf[2] = num >> 40;
  buf[3] = num >> 32;
  buf[4] = num >> 24;
  buf[5] = num >> 16;
  buf[6] = num >> 8;
  buf[7] = num;

  return buf;
}

int ConvertBytesToUint16(Uint8List b) {
  return b[1] | b[0] << 8;
}

Uint8List ConvertUint16ToBytes(int num) {
  var list = new Uint8List(2);

  list[0] = num >> 8;
  list[1] = num;

  return list;
}

Uint8List ConvertByteToBytes(int byte) {
  var list = new Uint8List(1);
  list[0] = byte;

  return list;
}

int ConvertBytesToUint8(Uint8List b) {
  return b[0];
}

int ConvertBytesToUint32(Uint8List b) {
  return b[3] | b[2] << 8 | b[1] << 16 | b[0] << 24;
}

int ConvertBytesToUint64(Uint8List b) {
  return b[7] |
      b[6] << 8 |
      b[5] << 16 |
      b[4] << 24 |
      b[3] << 32 |
      b[2] << 40 |
      b[1] << 48 |
      b[0] << 56;
}

String ConvertBytesToString(Uint8List b) {
  return String.fromCharCodes(b);
}

bool ConvertBoolToString(Uint8List b) {
  if (b[0] == utf8.encode('1')[0]) {
    return true;
  }

  return false;
}

Uint8List ConvertUint8ToBytes(int num) {
  return Uint8List.fromList([num]);
}

int ConvertBytesToByte(Uint8List b) {
  return b[0];
}

Uint8List ConvertUint32ToBytes(int num) {
  Uint8List buf = Uint8List(4);
  buf[0] = num >> 24;
  buf[1] = num >> 16;
  buf[2] = num >> 8;
  buf[3] = num;

  return buf;
}

//
Uint8List ConvertUint64ToBytes(int num) {
  Uint8List buf = Uint8List(8);
  buf[0] = num >> 56;
  buf[1] = num >> 48;
  buf[2] = num >> 40;
  buf[3] = num >> 32;
  buf[4] = num >> 24;
  buf[5] = num >> 16;
  buf[6] = num >> 8;
  buf[7] = num;

  return buf;
}

Uint8List ConvertStringToBytes(String str) {
  return Uint8List.fromList(str.codeUnits);
}

Uint8List ConvertBoolToBytes(bool b) {
  if (b) {
    return Uint8List.fromList([utf8.encode('1')[0]]);
  }

  return Uint8List.fromList([utf8.encode('0')[0]]);
}

Uint8List ConvertObjectToBytes(Message msg) {
  return msg.Marshal();
}

final objectBytesPrefixLength = _convertSizeToBytes(0).length;

Uint8List _convertSizeToBytes(int num) {
  ByteData buf = ByteData(4);
  buf.setUint32(0, num, Endian.big);

  return buf.buffer.asUint8List();
}
