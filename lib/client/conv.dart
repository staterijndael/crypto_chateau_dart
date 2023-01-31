import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/client/binary_iterator.dart';
import 'package:crypto_chateau_dart/client/models.dart';

int ConvertBytesToInt8(BinaryIterator b) {
  return b.bytes[0];
}

int ConvertBytesToInt32(BinaryIterator b) {
  return b.bytes[3] | b.bytes[2] << 8 | b.bytes[1] << 16 | b.bytes[0] << 24;
}

int ConvertBytesToInt64(BinaryIterator b) {
  return b.bytes[7] |
      b.bytes[6] << 8 |
      b.bytes[5] << 16 |
      b.bytes[4] << 24 |
      b.bytes[3] << 32 |
      b.bytes[2] << 40 |
      b.bytes[1] << 48 |
      b.bytes[0] << 56;
}

Uint8List ConvertInt8ToBytes(int num) {
  return Uint8List.fromList([num]);
}

Uint8List ConvertInt16ToBytes(int num) {
  var list = new Uint8List(2);

  list[0] = num >> 8;
  list[1] = num;

  return list;
}

Uint8List ConvertInt32ToBytes(int num) {
  Uint8List buf = Uint8List(4);
  buf[0] = num >> 24;
  buf[1] = num >> 16;
  buf[2] = num >> 8;
  buf[3] = num;

  return buf;
}

Uint8List ConvertSizeToBytes(int num) {
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

int ConvertBytesToUint16(BinaryIterator b) {
  return b.bytes[1] | b.bytes[0] << 8;
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

int ConvertBytesToUint8(BinaryIterator b) {
  return b.bytes[0];
}

int ConvertBytesToUint32(BinaryIterator b) {
  return b.bytes[3] | b.bytes[2] << 8 | b.bytes[1] << 16 | b.bytes[0] << 24;
}

int ConvertBytesToUint64(BinaryIterator b) {
  return b.bytes[7] |
      b.bytes[6] << 8 |
      b.bytes[5] << 16 |
      b.bytes[4] << 24 |
      b.bytes[3] << 32 |
      b.bytes[2] << 40 |
      b.bytes[1] << 48 |
      b.bytes[0] << 56;
}

String ConvertBytesToString(BinaryIterator b) {
  return String.fromCharCodes(b.bytes);
}

bool ConvertBytesToBool(BinaryIterator b) {
  return b.bytes == 0x01;
}

Uint8List ConvertUint8ToBytes(int num) {
  return Uint8List.fromList([num]);
}

int ConvertBytesToByte(BinaryIterator b) {
  return b.bytes[0];
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
