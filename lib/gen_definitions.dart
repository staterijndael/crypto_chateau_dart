import 'dart:async';
import 'dart:typed_data';
import 'package:crypto_chateau_dart/client/models.dart';
import 'package:crypto_chateau_dart/client/conv.dart';
import 'package:crypto_chateau_dart/transport/connection.dart';
import 'package:crypto_chateau_dart/transport/peer.dart';
import 'package:crypto_chateau_dart/transport/pipe.dart';
import 'dart:io';
import 'package:crypto_chateau_dart/client/binary_iterator.dart';
import 'package:crypto_chateau_dart/transport/multiplex_conn.dart';
import 'package:crypto_chateau_dart/transport/handler.dart';

var handlerHashMap = {
  "UserEndpoint": {
    "SendCode": [0x8D, 0x29, 0x10, 0xB8],
    "HandleCode": [0xC8, 0x46, 0x91, 0xDA],
    "RequiredOPK": [0xE6, 0xF3, 0x96, 0x42],
    "LoadOPK": [0x3, 0xB, 0x41, 0x2E],
    "FindUsersByPartNickname": [0x50, 0x85, 0x5D, 0xE],
    "GetInitMsgKeys": [0x12, 0x90, 0xA7, 0xFE],
    "Register": [0x7D, 0xCB, 0xAD, 0xA0],
    "AuthToken": [0x98, 0xF1, 0xCE, 0x10],
    "AuthCredentials": [0xA6, 0x7, 0x86, 0xA0],
    "SendMessagePM": [0x92, 0x4E, 0xFD, 0x10],
    "SendInitMessagePM": [0x86, 0xC2, 0xB4, 0x1A],
    "ListenUpdates": [0x28, 0xDC, 0x9C, 0xE9],
    "ReverseString": [0x86, 0xC, 0xAA, 0x80],
    "UpdateNotificationId": [0x79, 0xA4, 0x14, 0xEF],
  },
  "GroupEndpoint": {
    "CreateGroup": [0x7C, 0x8, 0x95, 0xB1],
    "SendMessageGroup": [0xDB, 0xE4, 0x60, 0x89],
  },
};

class BinaryCtx {
  int size;
  int arrSize;
  int pos;
  late BinaryIterator buf;
  late BinaryIterator arrBuf;

  BinaryCtx({
    this.size = 0,
    this.arrSize = 0,
    this.pos = 0,
  }) {
    buf = BinaryIterator(List.empty(growable: true));
    arrBuf = BinaryIterator(List.empty(growable: true));
  }
}

extension ExtendList<T> on List<T> {
  void extend(int newLength, T defaultValue) {
    assert(newLength >= 0);

    final lengthDifference = newLength - length;
    if (lengthDifference <= 0) {
      length = newLength;
      return;
    }

    addAll(List.filled(lengthDifference, defaultValue));
  }
}

class ConnectParams {
  String host;
  int port;
  bool isEncryptionEnabled;

  ConnectParams({required this.host, required this.port, required this.isEncryptionEnabled});
}

class Client {
  ConnectParams connectParams;
  late Peer peer;
  late MultiplexConnectionPool pool;
  Completer<void>? _completer;

  Client({required this.connectParams}) {
    _completer = _createCompleter();
  }

  Completer<void> _createCompleter() {
    _connect();
    return Completer<void>();
  }

  Future<void> _connect() async {
    final socket = await Socket.connect(connectParams.host, connectParams.port);
    final connection = Connection(socket);
    pool = MultiplexConnectionPool(connection);
    _completer!.complete();
  }

  Future<void> get connected => _completer!.future;

  Future<ReverseStringResponse> reverseString(ReverseStringReq request) async {
    final multiplexConn = pool.newMultiplexConnection();
    final peer = Peer(Pipe(multiplexConn));

    final resp = await peer.sendRequest(HandlerHash(hash: [0x86, 0xC, 0xAA, 0x80]), request, ReverseStringResponse(Res: ""));

    return resp;
  }
}

class ReverseStringReq implements Message {
  String Str;

  ReverseStringReq({
    required this.Str,
  });

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertSizeToBytes(Str.codeUnits.length));
    b.addAll(ConvertStringToBytes(Str));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    Str = ConvertBytesToString(binaryCtx.buf);
  }
}

class ReverseStringResponse implements Message {
  String Res;

  ReverseStringResponse({
    required this.Res,
  });

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertSizeToBytes(Res.codeUnits.length));
    b.addAll(ConvertStringToBytes(Res));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    Res = ConvertBytesToString(binaryCtx.buf);
  }
}
