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

ConvertBytesToObject(Message msg, Uint8List b) {
  var params = GetParams(b)[1];
  msg.Unmarshal(params);
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
  Uint8List buf = Uint8List(4);
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

List GetArray(Uint8List p) {
  if (p.isEmpty) {
    throw ("array is zero length");
  }

  if (p[0] != utf8.encode('[')[0]) {
    throw ("expected open brace");
  }

  int openSquareBracketCount = 1;
  int closeSquareBracketCount = 0;

  int i = 1;
  while (openSquareBracketCount != closeSquareBracketCount && i < p.length) {
    if (p[i] == utf8.encode('[')[0]) {
      openSquareBracketCount++;
    }

    if (p[i] == utf8.encode(']')[0]) {
      closeSquareBracketCount++;
    }

    i++;
  }

  if (openSquareBracketCount != closeSquareBracketCount) {
    throw ("expected end of array");
  }

  List values = splitBytes(p.sublist(1, i - 1), utf8.encode(',')[0]);
  for (int i = 0; i < values.length; i++) {
    values[i] = trimSpace(values[i]);
  }

  if (values[0][0] == utf8.encode('{')[0]) {
    values[0] = values[0].sublist(1);
  }

  if (values[values.length - 1][values[values.length - 1].length - 1] ==
      utf8.encode('}')[0]) {
    values[values.length - 1] =
        values[values.length - 1].sublist(values[values.length - 1].length - 2);
  }

  return [i, values];
}

Uint8List trimSpace(Uint8List b) {
  int leftBorder = 0;
  int rightBorder = b.length - 1;

  while (b[leftBorder] == utf8.encode(' ')[0]) {
    leftBorder++;
  }

  while (b[rightBorder] == utf8.encode(' ')[0]) {
    rightBorder--;
  }

  return b.sublist(leftBorder, rightBorder + 1);
}

List splitBytes(Uint8List b, int delimiter) {
  List arr = [];

  int lastSplitIndex = -1;

  for (int i = 0; i < b.length; i++) {
    if (b[i] == delimiter && (i == b.length - 1 || b[i + 1] != delimiter)) {
      arr.add(b.sublist(lastSplitIndex + 1, i));
      lastSplitIndex = i;
    }
  }

  if (lastSplitIndex != b.length - 1) {
    arr.add(b.sublist(lastSplitIndex + 1));
  }

  return arr;
}

//
List GetParams(Uint8List p) {
  Map<String, Uint8List> params = {};
  Uint8List paramBuf = Uint8List(p.length);
  Uint8List valueBuf = Uint8List(p.length);

  int paramBufLast = -1;
  int valueBufLast = -1;
  int paramBufIndex = 0;
  int valueBufIndex = 0;

  bool paramFilled = false;
  bool stringParsing = false;

  int openBraceCount = 0;
  int closeBraceCount = 0;

  int openSquareBracketCount = 0;
  int closeSquareBracketCount = 0;

  bool isArrParsing = false;

  for (var i = 0; i < p.length; i++) {
    int b = p[i];
    if ((b == utf8.encode(',')[0] &&
            paramBufLast != paramBuf.length - 1 &&
            valueBufLast != valueBuf.length - 1 &&
            openBraceCount == closeBraceCount + 1 &&
            (!isArrParsing ||
                openSquareBracketCount == closeSquareBracketCount)) ||
        (b == utf8.encode('}')[0] && openBraceCount == closeBraceCount + 1)) {
      if (b == utf8.encode('}')[0] && i != p.length - 1) {
        valueBuf[valueBufIndex] = b;
        valueBufIndex++;
        closeBraceCount++;
      }

      if (paramBufLast == paramBuf.length - 1 ||
          valueBufLast == valueBuf.length - 1) {
        throw ("incorrect message format: null value");
      }

      String param = String.fromCharCodes(
          paramBuf.sublist(paramBufLast + 1, paramBufIndex));
      Uint8List value = valueBuf.sublist(valueBufLast + 1, valueBufIndex);
      params[param] = value;

      paramBufLast = paramBufIndex - 1;
      valueBufLast = valueBufIndex - 1;

      paramFilled = false;
      isArrParsing = false;
    } else if (b == utf8.encode('[')[0]) {
      valueBuf[valueBufIndex] = b;
      valueBufIndex++;
      isArrParsing = true;
      openSquareBracketCount++;
    } else if (b == utf8.encode(']')[0]) {
      valueBuf[valueBufIndex] = b;
      valueBufIndex++;
      closeSquareBracketCount++;
    } else if (b == utf8.encode('{')[0]) {
      if (paramFilled) {
        valueBuf[valueBufIndex] = b;
        valueBufIndex++;
      }
      openBraceCount++;
    } else if (b == utf8.encode('}')[0]) {
      valueBuf[valueBufIndex] = b;
      valueBufIndex++;
      closeBraceCount++;
    } else if (b == utf8.encode(':')[0] &&
        stringParsing == false &&
        !paramFilled) {
      paramFilled = true;
    } else if (b == utf8.encode('"')[0]) {
      stringParsing = !stringParsing;
    } else {
      if (!paramFilled) {
        paramBuf[paramBufIndex] = b;
        paramBufIndex++;
      } else {
        valueBuf[valueBufIndex] = b;
        valueBufIndex++;
      }
    }
  }

  return [p.length, params];
}
