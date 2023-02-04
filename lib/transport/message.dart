import 'dart:io';

import 'package:crypto_chateau_dart/client/models.dart';
import 'package:crypto_chateau_dart/transport/conn.dart';

class MessageController {
  List<int> reservedData;
  int futurePacketLength;

  MessageController(
      {required this.reservedData, required this.futurePacketLength});

  Future<List<int>> getFullMessage(Conn tcpConn, int bufSize,
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
          int oldFuturePacketLength = futurePacketLength;
          futurePacketLength = 0;
          if (oldFuturePacketLength != buf.length) {
            reservedData = buf.sublist(oldFuturePacketLength);
          }
          return buf.sublist(0, oldFuturePacketLength);
        }
      }

      final List<int> localBuf;

      if (isRawTCP) {
        localBuf = await tcpConn.broadcastStream
            .where((data) => data != null)
            .firstWhere((data) => data.length > 0);
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
        int oldFuturePacketLength = futurePacketLength;
        futurePacketLength = 0;
        if (oldFuturePacketLength != buf.length) {
          reservedData = buf.sublist(oldFuturePacketLength);
        }
        return buf.sublist(0, oldFuturePacketLength);
      }
    }
  }
}
