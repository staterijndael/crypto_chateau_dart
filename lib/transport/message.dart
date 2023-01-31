import 'dart:io';

import 'package:crypto_chateau_dart/transport/conn.dart';

class FullMessage {
  List<int>? msg;
  List<int>? gotReservedData;
  int? gotFuturePacketLength;

  FullMessage({this.msg, this.gotReservedData, this.gotFuturePacketLength});
}

Future<FullMessage> getFullMessage(
    Conn tcpConn, int bufSize, List<int> reservedData, int futurePacketLength,
    {bool isRawTCP = false}) async {
  if (bufSize == 0) {
    bufSize = 1024;
  }

  var buf = List.filled(0, 0, growable: true);

  while (true) {
    if (reservedData.isNotEmpty) {
      if (futurePacketLength == 0) {
        final packetLength = reservedData[0] | reservedData[1] << 8;
        futurePacketLength = packetLength;
        reservedData = reservedData.sublist(2);
      }

      buf.addAll(reservedData);
      reservedData = List.filled(0, 0, growable: true);

      if (buf.length >= futurePacketLength) {
        if (futurePacketLength != buf.length) {
          reservedData = buf.sublist(futurePacketLength);
        }
        return FullMessage(
            msg: buf.sublist(0, futurePacketLength),
            gotFuturePacketLength: 0,
            gotReservedData: reservedData);
      }
    }

    final List<int> localBuf;

    if (isRawTCP) {
      localBuf = await tcpConn.first;
    } else {
      localBuf = await tcpConn.read(bufSize);
    }

    buf.addAll(localBuf);

    if (buf.isEmpty) {
      throw "EOF";
    }

    if (futurePacketLength == 0) {
      futurePacketLength = buf[0] | buf[1] << 8;
      buf = buf.sublist(2);
    }

    if (buf.length >= futurePacketLength) {
      if (futurePacketLength != buf.length) {
        reservedData = buf.sublist(futurePacketLength);
      }
      return FullMessage(
          msg: buf.sublist(0, futurePacketLength),
          gotFuturePacketLength: 0,
          gotReservedData: reservedData);
    }
  }
}
