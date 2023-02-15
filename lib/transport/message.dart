import 'dart:io';

import 'package:crypto_chateau_dart/client/models.dart';
import 'package:crypto_chateau_dart/transport/conn.dart';
import 'package:crypto_chateau_dart/transport/multiplex_conn.dart';

class MessageController {
  List<int> reservedData;
  int futurePacketLength;
  int messageCount = 0;

  MessageController(
      {required this.reservedData, required this.futurePacketLength});

  Future<List<int>> getFullMessage(Conn conn, int bufSize,
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
        if (await conn.streamIterator.moveNext()) {
          localBuf = conn.streamIterator.current;
        } else {
          throw ("something went wrong during get new data from tcp");
        }
      } else {
        localBuf = await conn.read;
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
