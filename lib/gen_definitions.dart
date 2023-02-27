import 'dart:async';
import 'dart:typed_data';
import 'package:crypto_chateau_dart/client/models.dart';
import 'package:crypto_chateau_dart/client/conv.dart';
import 'package:crypto_chateau_dart/transport/connection/connection.dart';
import 'package:crypto_chateau_dart/client/binary_iterator.dart';
import 'package:crypto_chateau_dart/transport/handler.dart';
import 'package:crypto_chateau_dart/version/version.dart';

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
  final ConnectParams connectParams;
  final MultiplexRequestLoop _pool;

  const Client._({
    required this.connectParams,
    required MultiplexRequestLoop pool,
  }) : _pool = pool;

  factory Client({
    required ConnectParams connectParams,
  }) {
    final encryption = Encryption();
    final connection =
        Connection.root(connectParams).logger().pipe().cipher(encryption).handshake(encryption).multiplex().pipe();

    return Client._(
      connectParams: connectParams,
      pool: MultiplexRequestLoop(connection),
    );
  }

  Future<ReverseStringResponseAlt> reverseString(ReverseStringRequestAlt request) => _pool.sendRequest(request);
}

class ReverseStringRequestAlt implements Request<ReverseStringResponseAlt> {
  static final _handlerHash = HandlerHash(hash: [0x86, 0xC, 0xAA, 0x80]);
  final String str;

  const ReverseStringRequestAlt({
    required this.str,
  });

  @override
  HandlerHash get handlerHash => _handlerHash;

  @override
  Uint8List marshal() {
    final builder = BytesBuilder(copy: false);

    var size = ConvertSizeToBytes(0);
    builder.add(size);
    builder.add(ConvertSizeToBytes(str.codeUnits.length));
    builder.add(ConvertStringToBytes(str));
    size = ConvertSizeToBytes(builder.length - size.length);
    final bytes = builder.takeBytes();

    for (int i = 0; i < size.length; i++) {
      bytes[i] = size[i];
    }

    builder.addByte(newProtocolByte());
    builder.add(_handlerHash.hash);
    builder.add(bytes);

    return builder.toBytes();
  }

  @override
  ReverseStringResponseAlt unmarshal(Uint8List bytes) {
    final b = BinaryIterator(bytes);
    BinaryCtx binaryCtx = BinaryCtx();

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    final res = ConvertBytesToString(binaryCtx.buf);

    return ReverseStringResponseAlt(
      res: res,
    );
  }
}

class ReverseStringResponseAlt implements Response {
  final String res;

  const ReverseStringResponseAlt({
    required this.res,
  });
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
