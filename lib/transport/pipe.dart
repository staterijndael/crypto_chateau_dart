import 'dart:io';

import 'package:crypto_chateau_dart/transport/conn.dart';
import 'package:crypto_chateau_dart/transport/message.dart';

class Pipe {
  Conn tcpConn;
  List<int>? reservedData;
  int? futurePacketLength;

  Pipe(this.tcpConn) {
    reservedData = List.empty();
    futurePacketLength = 0;
  }

  void write(List<int> p) async {
    var dataWithLength = List.filled(p.length + 2, 0);
    var convertedLength = p.length;
    dataWithLength[0] = convertedLength & 0xff;
    dataWithLength[1] = (convertedLength & 0xff00) >> 8;
    dataWithLength.setRange(2, dataWithLength.length, p);
    tcpConn.write(dataWithLength);
  }

  Future<List<int>> read({int bufSize = 1024}) async {
    if (bufSize == 0) {
      bufSize = 1024;
    }

    var fullMessage = await getFullMessage(
        tcpConn, bufSize + 2, reservedData!, futurePacketLength!);

    futurePacketLength = fullMessage.gotFuturePacketLength;
    reservedData = fullMessage.gotReservedData;

    return fullMessage.msg!;
  }
}
