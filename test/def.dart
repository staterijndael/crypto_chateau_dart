import 'dart:async';
import 'dart:typed_data';
import 'package:crypto_chateau_dart/client/models.dart';
import 'package:crypto_chateau_dart/client/conv.dart';
import 'package:crypto_chateau_dart/transport/connection/connection.dart';
import 'package:crypto_chateau_dart/client/binary_iterator.dart';
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
    "UpdateLTPK": [0xAC, 0x95, 0x39, 0x68],
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

    final lengthDifference = newLength - this.length;
    if (lengthDifference <= 0) {
      this.length = newLength;
      return;
    }

    this.addAll(List.filled(lengthDifference, defaultValue));
  }
}

class Client {
  final ConnectParams connectParams;
  final Peer _peer;

  const Client._({
    required this.connectParams,
    required Peer peer,
  }) : _peer = peer;

  factory Client({
    required ConnectParams connectParams,
  }) {
    final encryption = Encryption();
    final connection = Connection.root(connectParams).pipe().cipher(encryption);

    return Client._(
      connectParams: connectParams,
      peer: Peer(
        MultiplexConnection(
          connection,
        ),
      ),
    );
  }

// handlers

  Future<SendCodeResponse> sendCode(SendCodeRequest request) =>
      _peer.sendRequest(HandlerHash(hash: [0x8D, 0x29, 0x10, 0xB8]), request).then(SendCodeResponse.fromBytes);

  Future<HandleCodeResponse> handleCode(HandleCodeRequest request) =>
      _peer.sendRequest(HandlerHash(hash: [0xC8, 0x46, 0x91, 0xDA]), request).then(HandleCodeResponse.fromBytes);

  Future<RequiredOPKResponse> requiredOPK(RequiredOPKRequest request) =>
      _peer.sendRequest(HandlerHash(hash: [0xE6, 0xF3, 0x96, 0x42]), request).then(RequiredOPKResponse.fromBytes);

  Future<LoadOPKResponse> loadOPK(LoadOPKRequest request) =>
      _peer.sendRequest(HandlerHash(hash: [0x3, 0xB, 0x41, 0x2E]), request).then(LoadOPKResponse.fromBytes);

  Future<FindUsersByPartNicknameResponse> findUsersByPartNickname(FindUsersByPartNicknameRequest request) => _peer
      .sendRequest(HandlerHash(hash: [0x50, 0x85, 0x5D, 0xE]), request)
      .then(FindUsersByPartNicknameResponse.fromBytes);

  Future<GetInitMsgKeysResponse> getInitMsgKeys(GetInitMsgKeysRequest request) =>
      _peer.sendRequest(HandlerHash(hash: [0x12, 0x90, 0xA7, 0xFE]), request).then(GetInitMsgKeysResponse.fromBytes);

  Future<RegisterResponse> register(RegisterRequest request) =>
      _peer.sendRequest(HandlerHash(hash: [0x7D, 0xCB, 0xAD, 0xA0]), request).then(RegisterResponse.fromBytes);

  Future<AuthTokenResponse> authToken(AuthTokenRequest request) =>
      _peer.sendRequest(HandlerHash(hash: [0x98, 0xF1, 0xCE, 0x10]), request).then(AuthTokenResponse.fromBytes);

  Future<AuthCredentialsResponse> authCredentials(AuthCredentialsRequest request) =>
      _peer.sendRequest(HandlerHash(hash: [0xA6, 0x7, 0x86, 0xA0]), request).then(AuthCredentialsResponse.fromBytes);

  Future<SendMessagePMResponse> sendMessagePM(SendMessagePMRequest request) =>
      _peer.sendRequest(HandlerHash(hash: [0x92, 0x4E, 0xFD, 0x10]), request).then(SendMessagePMResponse.fromBytes);

  Future<SendInitMessagePMResponse> sendInitMessagePM(SendInitMessagePMRequest request) =>
      _peer.sendRequest(HandlerHash(hash: [0x86, 0xC2, 0xB4, 0x1A]), request).then(SendInitMessagePMResponse.fromBytes);

  Stream<PresentEvent> listenUpdates(ListenUpdatesReq request) =>
      _peer.sendStreamRequest(HandlerHash(hash: [0x28, 0xDC, 0x9C, 0xE9]), request).map(PresentEvent.fromBytes);

  Future<ReverseStringResponse> reverseString(ReverseStringReq request) =>
      _peer.sendRequest(HandlerHash(hash: [0x86, 0xC, 0xAA, 0x80]), request).then(ReverseStringResponse.fromBytes);

  Future<UpdateFcmTokenResp> updateNotificationId(UpdateFcmTokenReq request) =>
      _peer.sendRequest(HandlerHash(hash: [0x79, 0xA4, 0x14, 0xEF]), request).then(UpdateFcmTokenResp.fromBytes);

  Future<UpdateLTPKResponse> updateLTPK(UpdateLTPKRequest request) =>
      _peer.sendRequest(HandlerHash(hash: [0xAC, 0x95, 0x39, 0x68]), request).then(UpdateLTPKResponse.fromBytes);

  Future<CreateGroupResponse> createGroup(CreateGroupReq request) =>
      _peer.sendRequest(HandlerHash(hash: [0x7C, 0x8, 0x95, 0xB1]), request).then(CreateGroupResponse.fromBytes);

  Future<SendMessageGroupResp> sendMessageGroup(SendMessageGroupReq request) =>
      _peer.sendRequest(HandlerHash(hash: [0xDB, 0xE4, 0x60, 0x89]), request).then(SendMessageGroupResp.fromBytes);
}

class UpdateLTPKResponse implements Message {
  UpdateLTPKResponse();

  UpdateLTPKResponse Copy() => UpdateLTPKResponse();

  static UpdateLTPKResponse fromBytes(Uint8List bytes) => UpdateLTPKResponse()..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
  }
}

class UpdateLTPKRequest implements Message {
  List<int>? SessionToken;

  List<int>? LTPK;

  List<int>? LTPKSignature;

  UpdateLTPKRequest({
    required this.SessionToken,
    required this.LTPK,
    required this.LTPKSignature,
  });

  UpdateLTPKRequest Copy() => UpdateLTPKRequest(
      SessionToken: List.filled(0, 0xff, growable: true),
      LTPK: List.filled(0, 0xff, growable: true),
      LTPKSignature: List.filled(0, 0xff, growable: true));

  static UpdateLTPKRequest fromBytes(Uint8List bytes) => UpdateLTPKRequest(
      SessionToken: List.filled(0, 0xff, growable: true),
      LTPK: List.filled(0, 0xff, growable: true),
      LTPKSignature: List.filled(0, 0xff, growable: true))
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    List<int> arrBufLTPK = [];
    for (var elLTPK in LTPK!) {
      arrBufLTPK.addAll(ConvertByteToBytes(elLTPK));
    }
    b.addAll(ConvertSizeToBytes(arrBufLTPK.length));
    b.addAll(arrBufLTPK);
    List<int> arrBufLTPKSignature = [];
    for (var elLTPKSignature in LTPKSignature!) {
      arrBufLTPKSignature.addAll(ConvertByteToBytes(elLTPKSignature));
    }
    b.addAll(ConvertSizeToBytes(arrBufLTPKSignature.length));
    b.addAll(arrBufLTPKSignature);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyLTPK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyLTPK = false;

      int elLTPK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elLTPK = ConvertBytesToByte(binaryCtx.buf);

      LTPK!.add(elLTPK);
    }

    if (isEmptyLTPK) {
      LTPK = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyLTPKSignature = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyLTPKSignature = false;

      int elLTPKSignature;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elLTPKSignature = ConvertBytesToByte(binaryCtx.buf);

      LTPKSignature!.add(elLTPKSignature);
    }

    if (isEmptyLTPKSignature) {
      LTPKSignature = null;
    }
  }
}

class UpdateFcmTokenReq implements Message {
  List<int>? SessionToken;

  String FcmToken;

  UpdateFcmTokenReq({
    required this.SessionToken,
    required this.FcmToken,
  });

  UpdateFcmTokenReq Copy() => UpdateFcmTokenReq(SessionToken: List.filled(0, 0xff, growable: true), FcmToken: "");

  static UpdateFcmTokenReq fromBytes(Uint8List bytes) =>
      UpdateFcmTokenReq(SessionToken: List.filled(0, 0xff, growable: true), FcmToken: "")
        ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    b.addAll(ConvertSizeToBytes(FcmToken.codeUnits.length));
    b.addAll(ConvertStringToBytes(FcmToken));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    FcmToken = ConvertBytesToString(binaryCtx.buf);
  }
}

class UpdateFcmTokenResp implements Message {
  UpdateFcmTokenResp();

  UpdateFcmTokenResp Copy() => UpdateFcmTokenResp();

  static UpdateFcmTokenResp fromBytes(Uint8List bytes) => UpdateFcmTokenResp()..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
  }
}

class GroupMessage implements Message {
  List<int>? GroupIK;

  int MessageID;

  String MessageType;

  List<int> Content;

  List<Attachment> Attachments;

  GroupMessage({
    required this.GroupIK,
    required this.MessageID,
    required this.MessageType,
    required this.Content,
    required this.Attachments,
  });

  GroupMessage Copy() => GroupMessage(
      GroupIK: List.filled(0, 0xff, growable: true),
      MessageID: 0,
      MessageType: "",
      Content: List.filled(0, 0xff, growable: true),
      Attachments: List.filled(0, Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true)), growable: true));

  static GroupMessage fromBytes(Uint8List bytes) => GroupMessage(
      GroupIK: List.filled(0, 0xff, growable: true),
      MessageID: 0,
      MessageType: "",
      Content: List.filled(0, 0xff, growable: true),
      Attachments: List.filled(0, Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true)), growable: true))
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufGroupIK = [];
    for (var elGroupIK in GroupIK!) {
      arrBufGroupIK.addAll(ConvertByteToBytes(elGroupIK));
    }
    b.addAll(ConvertSizeToBytes(arrBufGroupIK.length));
    b.addAll(arrBufGroupIK);
    b.addAll(ConvertUint32ToBytes(MessageID));
    b.addAll(ConvertSizeToBytes(MessageType.codeUnits.length));
    b.addAll(ConvertStringToBytes(MessageType));
    List<int> arrBufContent = [];
    for (var elContent in Content) {
      arrBufContent.addAll(ConvertByteToBytes(elContent));
    }
    b.addAll(ConvertSizeToBytes(arrBufContent.length));
    b.addAll(arrBufContent);
    List<int> arrBufAttachments = [];
    for (var elAttachments in Attachments) {
      arrBufAttachments.addAll(elAttachments.Marshal());
    }
    b.addAll(ConvertSizeToBytes(arrBufAttachments.length));
    b.addAll(arrBufAttachments);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyGroupIK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyGroupIK = false;

      int elGroupIK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elGroupIK = ConvertBytesToByte(binaryCtx.buf);

      GroupIK!.add(elGroupIK);
    }

    if (isEmptyGroupIK) {
      GroupIK = null;
    }

    binaryCtx.buf = b.slice(4);
    MessageID = ConvertBytesToUint32(binaryCtx.buf);

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    MessageType = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      int elContent;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elContent = ConvertBytesToByte(binaryCtx.buf);

      Content.add(elContent);
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      Attachment elAttachments = Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true));

      binaryCtx.size = binaryCtx.arrBuf.nextSize();
      binaryCtx.buf = binaryCtx.arrBuf.slice(binaryCtx.size);
      elAttachments.Unmarshal(binaryCtx.buf);

      Attachments.add(elAttachments);
    }
  }
}

class SendMessageGroupReq implements Message {
  String MessageType;

  List<int>? GroupIK;

  List<int> Content;

  List<Attachment> Attachments;

  List<int>? SessionToken;

  SendMessageGroupReq({
    required this.MessageType,
    required this.GroupIK,
    required this.Content,
    required this.Attachments,
    required this.SessionToken,
  });

  SendMessageGroupReq Copy() => SendMessageGroupReq(
      MessageType: "",
      GroupIK: List.filled(0, 0xff, growable: true),
      Content: List.filled(0, 0xff, growable: true),
      Attachments: List.filled(0, Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true)), growable: true),
      SessionToken: List.filled(0, 0xff, growable: true));

  static SendMessageGroupReq fromBytes(Uint8List bytes) => SendMessageGroupReq(
      MessageType: "",
      GroupIK: List.filled(0, 0xff, growable: true),
      Content: List.filled(0, 0xff, growable: true),
      Attachments: List.filled(0, Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true)), growable: true),
      SessionToken: List.filled(0, 0xff, growable: true))
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertSizeToBytes(MessageType.codeUnits.length));
    b.addAll(ConvertStringToBytes(MessageType));
    List<int> arrBufGroupIK = [];
    for (var elGroupIK in GroupIK!) {
      arrBufGroupIK.addAll(ConvertByteToBytes(elGroupIK));
    }
    b.addAll(ConvertSizeToBytes(arrBufGroupIK.length));
    b.addAll(arrBufGroupIK);
    List<int> arrBufContent = [];
    for (var elContent in Content) {
      arrBufContent.addAll(ConvertByteToBytes(elContent));
    }
    b.addAll(ConvertSizeToBytes(arrBufContent.length));
    b.addAll(arrBufContent);
    List<int> arrBufAttachments = [];
    for (var elAttachments in Attachments) {
      arrBufAttachments.addAll(elAttachments.Marshal());
    }
    b.addAll(ConvertSizeToBytes(arrBufAttachments.length));
    b.addAll(arrBufAttachments);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
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
    MessageType = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyGroupIK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyGroupIK = false;

      int elGroupIK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elGroupIK = ConvertBytesToByte(binaryCtx.buf);

      GroupIK!.add(elGroupIK);
    }

    if (isEmptyGroupIK) {
      GroupIK = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      int elContent;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elContent = ConvertBytesToByte(binaryCtx.buf);

      Content.add(elContent);
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      Attachment elAttachments = Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true));

      binaryCtx.size = binaryCtx.arrBuf.nextSize();
      binaryCtx.buf = binaryCtx.arrBuf.slice(binaryCtx.size);
      elAttachments.Unmarshal(binaryCtx.buf);

      Attachments.add(elAttachments);
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }
  }
}

class SendMessageGroupResp implements Message {
  SendMessageGroupResp();

  SendMessageGroupResp Copy() => SendMessageGroupResp();

  static SendMessageGroupResp fromBytes(Uint8List bytes) => SendMessageGroupResp()..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
  }
}

class CreateGroupReq implements Message {
  List<int>? SessionToken;

  List<int>? IdentityKey;

  String Name;

  String Status;

  String PictureID;

  CreateGroupReq({
    required this.SessionToken,
    required this.IdentityKey,
    required this.Name,
    required this.Status,
    required this.PictureID,
  });

  CreateGroupReq Copy() => CreateGroupReq(
      SessionToken: List.filled(0, 0xff, growable: true),
      IdentityKey: List.filled(0, 0xff, growable: true),
      Name: "",
      Status: "",
      PictureID: "");

  static CreateGroupReq fromBytes(Uint8List bytes) => CreateGroupReq(
      SessionToken: List.filled(0, 0xff, growable: true),
      IdentityKey: List.filled(0, 0xff, growable: true),
      Name: "",
      Status: "",
      PictureID: "")
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    List<int> arrBufIdentityKey = [];
    for (var elIdentityKey in IdentityKey!) {
      arrBufIdentityKey.addAll(ConvertByteToBytes(elIdentityKey));
    }
    b.addAll(ConvertSizeToBytes(arrBufIdentityKey.length));
    b.addAll(arrBufIdentityKey);
    b.addAll(ConvertSizeToBytes(Name.codeUnits.length));
    b.addAll(ConvertStringToBytes(Name));
    b.addAll(ConvertSizeToBytes(Status.codeUnits.length));
    b.addAll(ConvertStringToBytes(Status));
    b.addAll(ConvertSizeToBytes(PictureID.codeUnits.length));
    b.addAll(ConvertStringToBytes(PictureID));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyIdentityKey = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyIdentityKey = false;

      int elIdentityKey;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elIdentityKey = ConvertBytesToByte(binaryCtx.buf);

      IdentityKey!.add(elIdentityKey);
    }

    if (isEmptyIdentityKey) {
      IdentityKey = null;
    }

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    Name = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    Status = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    PictureID = ConvertBytesToString(binaryCtx.buf);
  }
}

class CreateGroupResponse implements Message {
  CreateGroupResponse();

  CreateGroupResponse Copy() => CreateGroupResponse();

  static CreateGroupResponse fromBytes(Uint8List bytes) => CreateGroupResponse()..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
  }
}

class ReverseStringReq implements Message {
  String Str;

  ReverseStringReq({
    required this.Str,
  });

  ReverseStringReq Copy() => ReverseStringReq(Str: "");

  static ReverseStringReq fromBytes(Uint8List bytes) => ReverseStringReq(Str: "")..Unmarshal(BinaryIterator(bytes));

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

  ReverseStringResponse Copy() => ReverseStringResponse(Res: "");

  static ReverseStringResponse fromBytes(Uint8List bytes) =>
      ReverseStringResponse(Res: "")..Unmarshal(BinaryIterator(bytes));

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

class SendCodeRequest implements Message {
  String Phone;

  SendCodeRequest({
    required this.Phone,
  });

  SendCodeRequest Copy() => SendCodeRequest(Phone: "");

  static SendCodeRequest fromBytes(Uint8List bytes) => SendCodeRequest(Phone: "")..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertSizeToBytes(Phone.codeUnits.length));
    b.addAll(ConvertStringToBytes(Phone));
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
    Phone = ConvertBytesToString(binaryCtx.buf);
  }
}

class SendCodeResponse implements Message {
  SendCodeResponse();

  SendCodeResponse Copy() => SendCodeResponse();

  static SendCodeResponse fromBytes(Uint8List bytes) => SendCodeResponse()..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
  }
}

class HandleCodeRequest implements Message {
  String Phone;

  int Code;

  HandleCodeRequest({
    required this.Phone,
    required this.Code,
  });

  HandleCodeRequest Copy() => HandleCodeRequest(Phone: "", Code: 0);

  static HandleCodeRequest fromBytes(Uint8List bytes) =>
      HandleCodeRequest(Phone: "", Code: 0)..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertSizeToBytes(Phone.codeUnits.length));
    b.addAll(ConvertStringToBytes(Phone));
    b.addAll(ConvertIntToBytes(Code));
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
    Phone = ConvertBytesToString(binaryCtx.buf);
  }
}

class HandleCodeResponse implements Message {
  HandleCodeResponse();

  HandleCodeResponse Copy() => HandleCodeResponse();

  static HandleCodeResponse fromBytes(Uint8List bytes) => HandleCodeResponse()..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
  }
}

class RequiredOPKRequest implements Message {
  List<int>? SessionToken;

  RequiredOPKRequest({
    required this.SessionToken,
  });

  RequiredOPKRequest Copy() => RequiredOPKRequest(SessionToken: List.filled(0, 0xff, growable: true));

  static RequiredOPKRequest fromBytes(Uint8List bytes) =>
      RequiredOPKRequest(SessionToken: List.filled(0, 0xff, growable: true))..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }
  }
}

class RequiredOPKResponse implements Message {
  int Count;

  RequiredOPKResponse({
    required this.Count,
  });

  RequiredOPKResponse Copy() => RequiredOPKResponse(Count: 0);

  static RequiredOPKResponse fromBytes(Uint8List bytes) =>
      RequiredOPKResponse(Count: 0)..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertUint16ToBytes(Count));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();

    binaryCtx.buf = b.slice(2);
    Count = ConvertBytesToUint16(binaryCtx.buf);
  }
}

class LoadOPKRequest implements Message {
  List<int>? SessionToken;

  List<OPKPair> OPK;

  LoadOPKRequest({
    required this.SessionToken,
    required this.OPK,
  });

  LoadOPKRequest Copy() => LoadOPKRequest(
      SessionToken: List.filled(0, 0xff, growable: true),
      OPK: List.filled(0, OPKPair(OPKId: 0, OPK: List.filled(0, 0xff, growable: true)), growable: true));

  static LoadOPKRequest fromBytes(Uint8List bytes) => LoadOPKRequest(
      SessionToken: List.filled(0, 0xff, growable: true),
      OPK: List.filled(0, OPKPair(OPKId: 0, OPK: List.filled(0, 0xff, growable: true)), growable: true))
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    List<int> arrBufOPK = [];
    for (var elOPK in OPK) {
      arrBufOPK.addAll(elOPK.Marshal());
    }
    b.addAll(ConvertSizeToBytes(arrBufOPK.length));
    b.addAll(arrBufOPK);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      OPKPair elOPK = OPKPair(OPKId: 0, OPK: List.filled(0, 0xff, growable: true));

      binaryCtx.size = binaryCtx.arrBuf.nextSize();
      binaryCtx.buf = binaryCtx.arrBuf.slice(binaryCtx.size);
      elOPK.Unmarshal(binaryCtx.buf);

      OPK.add(elOPK);
    }
  }
}

class OPKPair implements Message {
  int OPKId;

  List<int>? OPK;

  OPKPair({
    required this.OPKId,
    required this.OPK,
  });

  OPKPair Copy() => OPKPair(OPKId: 0, OPK: List.filled(0, 0xff, growable: true));

  static OPKPair fromBytes(Uint8List bytes) =>
      OPKPair(OPKId: 0, OPK: List.filled(0, 0xff, growable: true))..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertUint32ToBytes(OPKId));
    List<int> arrBufOPK = [];
    for (var elOPK in OPK!) {
      arrBufOPK.addAll(ConvertByteToBytes(elOPK));
    }
    b.addAll(ConvertSizeToBytes(arrBufOPK.length));
    b.addAll(arrBufOPK);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();

    binaryCtx.buf = b.slice(4);
    OPKId = ConvertBytesToUint32(binaryCtx.buf);

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyOPK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyOPK = false;

      int elOPK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elOPK = ConvertBytesToByte(binaryCtx.buf);

      OPK!.add(elOPK);
    }

    if (isEmptyOPK) {
      OPK = null;
    }
  }
}

class LoadOPKResponse implements Message {
  LoadOPKResponse();

  LoadOPKResponse Copy() => LoadOPKResponse();

  static LoadOPKResponse fromBytes(Uint8List bytes) => LoadOPKResponse()..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
  }
}

class FindUsersByPartNicknameRequest implements Message {
  List<int>? SessionToken;

  String PartNickname;

  FindUsersByPartNicknameRequest({
    required this.SessionToken,
    required this.PartNickname,
  });

  FindUsersByPartNicknameRequest Copy() =>
      FindUsersByPartNicknameRequest(SessionToken: List.filled(0, 0xff, growable: true), PartNickname: "");

  static FindUsersByPartNicknameRequest fromBytes(Uint8List bytes) =>
      FindUsersByPartNicknameRequest(SessionToken: List.filled(0, 0xff, growable: true), PartNickname: "")
        ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    b.addAll(ConvertSizeToBytes(PartNickname.codeUnits.length));
    b.addAll(ConvertStringToBytes(PartNickname));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    PartNickname = ConvertBytesToString(binaryCtx.buf);
  }
}

class FindUsersByPartNicknameResponse implements Message {
  List<PresentUser> Users;

  FindUsersByPartNicknameResponse({
    required this.Users,
  });

  FindUsersByPartNicknameResponse Copy() => FindUsersByPartNicknameResponse(
      Users: List.filled(
          0, PresentUser(IdentityKey: List.filled(0, 0xff, growable: true), Nickname: "", PictureID: "", Status: ""),
          growable: true));

  static FindUsersByPartNicknameResponse fromBytes(Uint8List bytes) => FindUsersByPartNicknameResponse(
      Users: List.filled(
          0, PresentUser(IdentityKey: List.filled(0, 0xff, growable: true), Nickname: "", PictureID: "", Status: ""),
          growable: true))
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufUsers = [];
    for (var elUsers in Users) {
      arrBufUsers.addAll(elUsers.Marshal());
    }
    b.addAll(ConvertSizeToBytes(arrBufUsers.length));
    b.addAll(arrBufUsers);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      PresentUser elUsers =
      PresentUser(IdentityKey: List.filled(0, 0xff, growable: true), Nickname: "", PictureID: "", Status: "");

      binaryCtx.size = binaryCtx.arrBuf.nextSize();
      binaryCtx.buf = binaryCtx.arrBuf.slice(binaryCtx.size);
      elUsers.Unmarshal(binaryCtx.buf);

      Users.add(elUsers);
    }
  }
}

class PresentUser implements Message {
  List<int>? IdentityKey;

  String Nickname;

  String PictureID;

  String Status;

  PresentUser({
    required this.IdentityKey,
    required this.Nickname,
    required this.PictureID,
    required this.Status,
  });

  PresentUser Copy() =>
      PresentUser(IdentityKey: List.filled(0, 0xff, growable: true), Nickname: "", PictureID: "", Status: "");

  static PresentUser fromBytes(Uint8List bytes) =>
      PresentUser(IdentityKey: List.filled(0, 0xff, growable: true), Nickname: "", PictureID: "", Status: "")
        ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufIdentityKey = [];
    for (var elIdentityKey in IdentityKey!) {
      arrBufIdentityKey.addAll(ConvertByteToBytes(elIdentityKey));
    }
    b.addAll(ConvertSizeToBytes(arrBufIdentityKey.length));
    b.addAll(arrBufIdentityKey);
    b.addAll(ConvertSizeToBytes(Nickname.codeUnits.length));
    b.addAll(ConvertStringToBytes(Nickname));
    b.addAll(ConvertSizeToBytes(PictureID.codeUnits.length));
    b.addAll(ConvertStringToBytes(PictureID));
    b.addAll(ConvertSizeToBytes(Status.codeUnits.length));
    b.addAll(ConvertStringToBytes(Status));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyIdentityKey = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyIdentityKey = false;

      int elIdentityKey;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elIdentityKey = ConvertBytesToByte(binaryCtx.buf);

      IdentityKey!.add(elIdentityKey);
    }

    if (isEmptyIdentityKey) {
      IdentityKey = null;
    }

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    Nickname = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    PictureID = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    Status = ConvertBytesToString(binaryCtx.buf);
  }
}

class GetInitMsgKeysRequest implements Message {
  List<int>? SessionToken;

  List<int>? IdentityKey;

  GetInitMsgKeysRequest({
    required this.SessionToken,
    required this.IdentityKey,
  });

  GetInitMsgKeysRequest Copy() => GetInitMsgKeysRequest(
      SessionToken: List.filled(0, 0xff, growable: true), IdentityKey: List.filled(0, 0xff, growable: true));

  static GetInitMsgKeysRequest fromBytes(Uint8List bytes) => GetInitMsgKeysRequest(
      SessionToken: List.filled(0, 0xff, growable: true), IdentityKey: List.filled(0, 0xff, growable: true))
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    List<int> arrBufIdentityKey = [];
    for (var elIdentityKey in IdentityKey!) {
      arrBufIdentityKey.addAll(ConvertByteToBytes(elIdentityKey));
    }
    b.addAll(ConvertSizeToBytes(arrBufIdentityKey.length));
    b.addAll(arrBufIdentityKey);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyIdentityKey = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyIdentityKey = false;

      int elIdentityKey;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elIdentityKey = ConvertBytesToByte(binaryCtx.buf);

      IdentityKey!.add(elIdentityKey);
    }

    if (isEmptyIdentityKey) {
      IdentityKey = null;
    }
  }
}

class GetInitMsgKeysResponse implements Message {
  int OPKId;

  List<int>? OPK;

  List<int>? SignedLTPK;

  List<int>? Signature;

  GetInitMsgKeysResponse({
    required this.OPKId,
    required this.OPK,
    required this.SignedLTPK,
    required this.Signature,
  });

  GetInitMsgKeysResponse Copy() => GetInitMsgKeysResponse(
      OPKId: 0,
      OPK: List.filled(0, 0xff, growable: true),
      SignedLTPK: List.filled(0, 0xff, growable: true),
      Signature: List.filled(0, 0xff, growable: true));

  static GetInitMsgKeysResponse fromBytes(Uint8List bytes) => GetInitMsgKeysResponse(
      OPKId: 0,
      OPK: List.filled(0, 0xff, growable: true),
      SignedLTPK: List.filled(0, 0xff, growable: true),
      Signature: List.filled(0, 0xff, growable: true))
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertUint32ToBytes(OPKId));
    List<int> arrBufOPK = [];
    for (var elOPK in OPK!) {
      arrBufOPK.addAll(ConvertByteToBytes(elOPK));
    }
    b.addAll(ConvertSizeToBytes(arrBufOPK.length));
    b.addAll(arrBufOPK);
    List<int> arrBufSignedLTPK = [];
    for (var elSignedLTPK in SignedLTPK!) {
      arrBufSignedLTPK.addAll(ConvertByteToBytes(elSignedLTPK));
    }
    b.addAll(ConvertSizeToBytes(arrBufSignedLTPK.length));
    b.addAll(arrBufSignedLTPK);
    List<int> arrBufSignature = [];
    for (var elSignature in Signature!) {
      arrBufSignature.addAll(ConvertByteToBytes(elSignature));
    }
    b.addAll(ConvertSizeToBytes(arrBufSignature.length));
    b.addAll(arrBufSignature);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();

    binaryCtx.buf = b.slice(4);
    OPKId = ConvertBytesToUint32(binaryCtx.buf);

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyOPK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyOPK = false;

      int elOPK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elOPK = ConvertBytesToByte(binaryCtx.buf);

      OPK!.add(elOPK);
    }

    if (isEmptyOPK) {
      OPK = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySignedLTPK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySignedLTPK = false;

      int elSignedLTPK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSignedLTPK = ConvertBytesToByte(binaryCtx.buf);

      SignedLTPK!.add(elSignedLTPK);
    }

    if (isEmptySignedLTPK) {
      SignedLTPK = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySignature = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySignature = false;

      int elSignature;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSignature = ConvertBytesToByte(binaryCtx.buf);

      Signature!.add(elSignature);
    }

    if (isEmptySignature) {
      Signature = null;
    }
  }
}

class RegisterRequest implements Message {
  String Phone;

  int Code;

  String Nickname;

  List<int>? PassHash;

  String DeviceID;

  String DeviceName;

  String FcmToken;

  List<int>? LTPK;

  List<int>? LTPKSignature;

  List<int>? IdentityKey;

  RegisterRequest({
    required this.Phone,
    required this.Code,
    required this.Nickname,
    required this.PassHash,
    required this.DeviceID,
    required this.DeviceName,
    required this.FcmToken,
    required this.LTPK,
    required this.LTPKSignature,
    required this.IdentityKey,
  });

  RegisterRequest Copy() => RegisterRequest(
      Phone: "",
      Code: 0,
      Nickname: "",
      PassHash: List.filled(0, 0xff, growable: true),
      DeviceID: "",
      DeviceName: "",
      FcmToken: "",
      LTPK: List.filled(0, 0xff, growable: true),
      LTPKSignature: List.filled(0, 0xff, growable: true),
      IdentityKey: List.filled(0, 0xff, growable: true));

  static RegisterRequest fromBytes(Uint8List bytes) => RegisterRequest(
      Phone: "",
      Code: 0,
      Nickname: "",
      PassHash: List.filled(0, 0xff, growable: true),
      DeviceID: "",
      DeviceName: "",
      FcmToken: "",
      LTPK: List.filled(0, 0xff, growable: true),
      LTPKSignature: List.filled(0, 0xff, growable: true),
      IdentityKey: List.filled(0, 0xff, growable: true))
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertSizeToBytes(Phone.codeUnits.length));
    b.addAll(ConvertStringToBytes(Phone));
    b.addAll(ConvertIntToBytes(Code));
    b.addAll(ConvertSizeToBytes(Nickname.codeUnits.length));
    b.addAll(ConvertStringToBytes(Nickname));
    List<int> arrBufPassHash = [];
    for (var elPassHash in PassHash!) {
      arrBufPassHash.addAll(ConvertByteToBytes(elPassHash));
    }
    b.addAll(ConvertSizeToBytes(arrBufPassHash.length));
    b.addAll(arrBufPassHash);
    b.addAll(ConvertSizeToBytes(DeviceID.codeUnits.length));
    b.addAll(ConvertStringToBytes(DeviceID));
    b.addAll(ConvertSizeToBytes(DeviceName.codeUnits.length));
    b.addAll(ConvertStringToBytes(DeviceName));
    b.addAll(ConvertSizeToBytes(FcmToken.codeUnits.length));
    b.addAll(ConvertStringToBytes(FcmToken));
    List<int> arrBufLTPK = [];
    for (var elLTPK in LTPK!) {
      arrBufLTPK.addAll(ConvertByteToBytes(elLTPK));
    }
    b.addAll(ConvertSizeToBytes(arrBufLTPK.length));
    b.addAll(arrBufLTPK);
    List<int> arrBufLTPKSignature = [];
    for (var elLTPKSignature in LTPKSignature!) {
      arrBufLTPKSignature.addAll(ConvertByteToBytes(elLTPKSignature));
    }
    b.addAll(ConvertSizeToBytes(arrBufLTPKSignature.length));
    b.addAll(arrBufLTPKSignature);
    List<int> arrBufIdentityKey = [];
    for (var elIdentityKey in IdentityKey!) {
      arrBufIdentityKey.addAll(ConvertByteToBytes(elIdentityKey));
    }
    b.addAll(ConvertSizeToBytes(arrBufIdentityKey.length));
    b.addAll(arrBufIdentityKey);
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
    Phone = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    Nickname = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyPassHash = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyPassHash = false;

      int elPassHash;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elPassHash = ConvertBytesToByte(binaryCtx.buf);

      PassHash!.add(elPassHash);
    }

    if (isEmptyPassHash) {
      PassHash = null;
    }

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    DeviceID = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    DeviceName = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    FcmToken = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyLTPK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyLTPK = false;

      int elLTPK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elLTPK = ConvertBytesToByte(binaryCtx.buf);

      LTPK!.add(elLTPK);
    }

    if (isEmptyLTPK) {
      LTPK = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyLTPKSignature = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyLTPKSignature = false;

      int elLTPKSignature;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elLTPKSignature = ConvertBytesToByte(binaryCtx.buf);

      LTPKSignature!.add(elLTPKSignature);
    }

    if (isEmptyLTPKSignature) {
      LTPKSignature = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyIdentityKey = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyIdentityKey = false;

      int elIdentityKey;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elIdentityKey = ConvertBytesToByte(binaryCtx.buf);

      IdentityKey!.add(elIdentityKey);
    }

    if (isEmptyIdentityKey) {
      IdentityKey = null;
    }
  }
}

class RegisterResponse implements Message {
  List<int>? SessionToken;

  RegisterResponse({
    required this.SessionToken,
  });

  RegisterResponse Copy() => RegisterResponse(SessionToken: List.filled(0, 0xff, growable: true));

  static RegisterResponse fromBytes(Uint8List bytes) =>
      RegisterResponse(SessionToken: List.filled(0, 0xff, growable: true))..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }
  }
}

class AuthTokenRequest implements Message {
  List<int>? SessionToken;

  AuthTokenRequest({
    required this.SessionToken,
  });

  AuthTokenRequest Copy() => AuthTokenRequest(SessionToken: List.filled(0, 0xff, growable: true));

  static AuthTokenRequest fromBytes(Uint8List bytes) =>
      AuthTokenRequest(SessionToken: List.filled(0, 0xff, growable: true))..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }
  }
}

class AuthTokenResponse implements Message {
  List<int>? SessionToken;

  AuthTokenResponse({
    required this.SessionToken,
  });

  AuthTokenResponse Copy() => AuthTokenResponse(SessionToken: List.filled(0, 0xff, growable: true));

  static AuthTokenResponse fromBytes(Uint8List bytes) =>
      AuthTokenResponse(SessionToken: List.filled(0, 0xff, growable: true))..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }
  }
}

class AuthCredentialsRequest implements Message {
  String Phone;

  List<int>? PassHash;

  String DeviceID;

  String DeviceName;

  AuthCredentialsRequest({
    required this.Phone,
    required this.PassHash,
    required this.DeviceID,
    required this.DeviceName,
  });

  AuthCredentialsRequest Copy() =>
      AuthCredentialsRequest(Phone: "", PassHash: List.filled(0, 0xff, growable: true), DeviceID: "", DeviceName: "");

  static AuthCredentialsRequest fromBytes(Uint8List bytes) =>
      AuthCredentialsRequest(Phone: "", PassHash: List.filled(0, 0xff, growable: true), DeviceID: "", DeviceName: "")
        ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertSizeToBytes(Phone.codeUnits.length));
    b.addAll(ConvertStringToBytes(Phone));
    List<int> arrBufPassHash = [];
    for (var elPassHash in PassHash!) {
      arrBufPassHash.addAll(ConvertByteToBytes(elPassHash));
    }
    b.addAll(ConvertSizeToBytes(arrBufPassHash.length));
    b.addAll(arrBufPassHash);
    b.addAll(ConvertSizeToBytes(DeviceID.codeUnits.length));
    b.addAll(ConvertStringToBytes(DeviceID));
    b.addAll(ConvertSizeToBytes(DeviceName.codeUnits.length));
    b.addAll(ConvertStringToBytes(DeviceName));
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
    Phone = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyPassHash = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyPassHash = false;

      int elPassHash;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elPassHash = ConvertBytesToByte(binaryCtx.buf);

      PassHash!.add(elPassHash);
    }

    if (isEmptyPassHash) {
      PassHash = null;
    }

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    DeviceID = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    DeviceName = ConvertBytesToString(binaryCtx.buf);
  }
}

class AuthCredentialsResponse implements Message {
  List<int>? SessionToken;

  AuthCredentialsResponse({
    required this.SessionToken,
  });

  AuthCredentialsResponse Copy() => AuthCredentialsResponse(SessionToken: List.filled(0, 0xff, growable: true));

  static AuthCredentialsResponse fromBytes(Uint8List bytes) =>
      AuthCredentialsResponse(SessionToken: List.filled(0, 0xff, growable: true))..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }
  }
}

class Attachment implements Message {
  String Type;

  List<int> Payload;

  Attachment({
    required this.Type,
    required this.Payload,
  });

  Attachment Copy() => Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true));

  static Attachment fromBytes(Uint8List bytes) =>
      Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true))..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertSizeToBytes(Type.codeUnits.length));
    b.addAll(ConvertStringToBytes(Type));
    List<int> arrBufPayload = [];
    for (var elPayload in Payload) {
      arrBufPayload.addAll(ConvertByteToBytes(elPayload));
    }
    b.addAll(ConvertSizeToBytes(arrBufPayload.length));
    b.addAll(arrBufPayload);
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
    Type = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      int elPayload;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elPayload = ConvertBytesToByte(binaryCtx.buf);

      Payload.add(elPayload);
    }
  }
}

class SendMessagePMRequest implements Message {
  String MessageType;

  List<int>? ReceiverIK;

  List<int>? RSPK;

  List<int> Content;

  List<Attachment> Attachments;

  List<int>? SessionToken;

  SendMessagePMRequest({
    required this.MessageType,
    required this.ReceiverIK,
    required this.RSPK,
    required this.Content,
    required this.Attachments,
    required this.SessionToken,
  });

  SendMessagePMRequest Copy() => SendMessagePMRequest(
      MessageType: "",
      ReceiverIK: List.filled(0, 0xff, growable: true),
      RSPK: List.filled(0, 0xff, growable: true),
      Content: List.filled(0, 0xff, growable: true),
      Attachments: List.filled(0, Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true)), growable: true),
      SessionToken: List.filled(0, 0xff, growable: true));

  static SendMessagePMRequest fromBytes(Uint8List bytes) => SendMessagePMRequest(
      MessageType: "",
      ReceiverIK: List.filled(0, 0xff, growable: true),
      RSPK: List.filled(0, 0xff, growable: true),
      Content: List.filled(0, 0xff, growable: true),
      Attachments: List.filled(0, Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true)), growable: true),
      SessionToken: List.filled(0, 0xff, growable: true))
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertSizeToBytes(MessageType.codeUnits.length));
    b.addAll(ConvertStringToBytes(MessageType));
    List<int> arrBufReceiverIK = [];
    for (var elReceiverIK in ReceiverIK!) {
      arrBufReceiverIK.addAll(ConvertByteToBytes(elReceiverIK));
    }
    b.addAll(ConvertSizeToBytes(arrBufReceiverIK.length));
    b.addAll(arrBufReceiverIK);
    List<int> arrBufRSPK = [];
    for (var elRSPK in RSPK!) {
      arrBufRSPK.addAll(ConvertByteToBytes(elRSPK));
    }
    b.addAll(ConvertSizeToBytes(arrBufRSPK.length));
    b.addAll(arrBufRSPK);
    List<int> arrBufContent = [];
    for (var elContent in Content) {
      arrBufContent.addAll(ConvertByteToBytes(elContent));
    }
    b.addAll(ConvertSizeToBytes(arrBufContent.length));
    b.addAll(arrBufContent);
    List<int> arrBufAttachments = [];
    for (var elAttachments in Attachments) {
      arrBufAttachments.addAll(elAttachments.Marshal());
    }
    b.addAll(ConvertSizeToBytes(arrBufAttachments.length));
    b.addAll(arrBufAttachments);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
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
    MessageType = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyReceiverIK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyReceiverIK = false;

      int elReceiverIK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elReceiverIK = ConvertBytesToByte(binaryCtx.buf);

      ReceiverIK!.add(elReceiverIK);
    }

    if (isEmptyReceiverIK) {
      ReceiverIK = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyRSPK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyRSPK = false;

      int elRSPK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elRSPK = ConvertBytesToByte(binaryCtx.buf);

      RSPK!.add(elRSPK);
    }

    if (isEmptyRSPK) {
      RSPK = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      int elContent;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elContent = ConvertBytesToByte(binaryCtx.buf);

      Content.add(elContent);
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      Attachment elAttachments = Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true));

      binaryCtx.size = binaryCtx.arrBuf.nextSize();
      binaryCtx.buf = binaryCtx.arrBuf.slice(binaryCtx.size);
      elAttachments.Unmarshal(binaryCtx.buf);

      Attachments.add(elAttachments);
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }
  }
}

class SendMessagePMResponse implements Message {
  int MessageID;

  SendMessagePMResponse({
    required this.MessageID,
  });

  SendMessagePMResponse Copy() => SendMessagePMResponse(MessageID: 0);

  static SendMessagePMResponse fromBytes(Uint8List bytes) =>
      SendMessagePMResponse(MessageID: 0)..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertUint32ToBytes(MessageID));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();

    binaryCtx.buf = b.slice(4);
    MessageID = ConvertBytesToUint32(binaryCtx.buf);
  }
}

class PresentEvent implements Message {
  int MonotonicEventID;

  String Type;

  List<int> Payload;

  int CreatedAt;

  PresentEvent({
    required this.MonotonicEventID,
    required this.Type,
    required this.Payload,
    required this.CreatedAt,
  });

  PresentEvent Copy() =>
      PresentEvent(MonotonicEventID: 0, Type: "", Payload: List.filled(0, 0xff, growable: true), CreatedAt: 0);

  static PresentEvent fromBytes(Uint8List bytes) =>
      PresentEvent(MonotonicEventID: 0, Type: "", Payload: List.filled(0, 0xff, growable: true), CreatedAt: 0)
        ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    b.addAll(ConvertUint64ToBytes(MonotonicEventID));
    b.addAll(ConvertSizeToBytes(Type.codeUnits.length));
    b.addAll(ConvertStringToBytes(Type));
    List<int> arrBufPayload = [];
    for (var elPayload in Payload) {
      arrBufPayload.addAll(ConvertByteToBytes(elPayload));
    }
    b.addAll(ConvertSizeToBytes(arrBufPayload.length));
    b.addAll(arrBufPayload);
    b.addAll(ConvertInt64ToBytes(CreatedAt));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();

    binaryCtx.buf = b.slice(8);
    MonotonicEventID = ConvertBytesToUint64(binaryCtx.buf);

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    Type = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      int elPayload;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elPayload = ConvertBytesToByte(binaryCtx.buf);

      Payload.add(elPayload);
    }

    binaryCtx.buf = b.slice(8);
    CreatedAt = ConvertBytesToInt64(binaryCtx.buf);
  }
}

class PmMessage implements Message {
  List<int>? RemoteIK;

  List<int>? RSPK;

  int MessageID;

  String MessageType;

  List<int> Content;

  List<Attachment> Attachments;

  PmMessage({
    required this.RemoteIK,
    required this.RSPK,
    required this.MessageID,
    required this.MessageType,
    required this.Content,
    required this.Attachments,
  });

  PmMessage Copy() => PmMessage(
      RemoteIK: List.filled(0, 0xff, growable: true),
      RSPK: List.filled(0, 0xff, growable: true),
      MessageID: 0,
      MessageType: "",
      Content: List.filled(0, 0xff, growable: true),
      Attachments: List.filled(0, Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true)), growable: true));

  static PmMessage fromBytes(Uint8List bytes) => PmMessage(
      RemoteIK: List.filled(0, 0xff, growable: true),
      RSPK: List.filled(0, 0xff, growable: true),
      MessageID: 0,
      MessageType: "",
      Content: List.filled(0, 0xff, growable: true),
      Attachments: List.filled(0, Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true)), growable: true))
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufRemoteIK = [];
    for (var elRemoteIK in RemoteIK!) {
      arrBufRemoteIK.addAll(ConvertByteToBytes(elRemoteIK));
    }
    b.addAll(ConvertSizeToBytes(arrBufRemoteIK.length));
    b.addAll(arrBufRemoteIK);
    List<int> arrBufRSPK = [];
    for (var elRSPK in RSPK!) {
      arrBufRSPK.addAll(ConvertByteToBytes(elRSPK));
    }
    b.addAll(ConvertSizeToBytes(arrBufRSPK.length));
    b.addAll(arrBufRSPK);
    b.addAll(ConvertUint32ToBytes(MessageID));
    b.addAll(ConvertSizeToBytes(MessageType.codeUnits.length));
    b.addAll(ConvertStringToBytes(MessageType));
    List<int> arrBufContent = [];
    for (var elContent in Content) {
      arrBufContent.addAll(ConvertByteToBytes(elContent));
    }
    b.addAll(ConvertSizeToBytes(arrBufContent.length));
    b.addAll(arrBufContent);
    List<int> arrBufAttachments = [];
    for (var elAttachments in Attachments) {
      arrBufAttachments.addAll(elAttachments.Marshal());
    }
    b.addAll(ConvertSizeToBytes(arrBufAttachments.length));
    b.addAll(arrBufAttachments);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyRemoteIK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyRemoteIK = false;

      int elRemoteIK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elRemoteIK = ConvertBytesToByte(binaryCtx.buf);

      RemoteIK!.add(elRemoteIK);
    }

    if (isEmptyRemoteIK) {
      RemoteIK = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyRSPK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyRSPK = false;

      int elRSPK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elRSPK = ConvertBytesToByte(binaryCtx.buf);

      RSPK!.add(elRSPK);
    }

    if (isEmptyRSPK) {
      RSPK = null;
    }

    binaryCtx.buf = b.slice(4);
    MessageID = ConvertBytesToUint32(binaryCtx.buf);

    binaryCtx.size = b.nextSize();
    binaryCtx.buf = b.slice(binaryCtx.size);
    MessageType = ConvertBytesToString(binaryCtx.buf);

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      int elContent;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elContent = ConvertBytesToByte(binaryCtx.buf);

      Content.add(elContent);
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    while (binaryCtx.arrBuf.hasNext()) {
      Attachment elAttachments = Attachment(Type: "", Payload: List.filled(0, 0xff, growable: true));

      binaryCtx.size = binaryCtx.arrBuf.nextSize();
      binaryCtx.buf = binaryCtx.arrBuf.slice(binaryCtx.size);
      elAttachments.Unmarshal(binaryCtx.buf);

      Attachments.add(elAttachments);
    }
  }
}

class PmInitMessage implements Message {
  List<int>? RemoteIK;

  List<int>? RemoteEK;

  int UsedOPKMarkID;

  PmInitMessage({
    required this.RemoteIK,
    required this.RemoteEK,
    required this.UsedOPKMarkID,
  });

  PmInitMessage Copy() => PmInitMessage(
      RemoteIK: List.filled(0, 0xff, growable: true), RemoteEK: List.filled(0, 0xff, growable: true), UsedOPKMarkID: 0);

  static PmInitMessage fromBytes(Uint8List bytes) => PmInitMessage(
      RemoteIK: List.filled(0, 0xff, growable: true), RemoteEK: List.filled(0, 0xff, growable: true), UsedOPKMarkID: 0)
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufRemoteIK = [];
    for (var elRemoteIK in RemoteIK!) {
      arrBufRemoteIK.addAll(ConvertByteToBytes(elRemoteIK));
    }
    b.addAll(ConvertSizeToBytes(arrBufRemoteIK.length));
    b.addAll(arrBufRemoteIK);
    List<int> arrBufRemoteEK = [];
    for (var elRemoteEK in RemoteEK!) {
      arrBufRemoteEK.addAll(ConvertByteToBytes(elRemoteEK));
    }
    b.addAll(ConvertSizeToBytes(arrBufRemoteEK.length));
    b.addAll(arrBufRemoteEK);
    b.addAll(ConvertIntToBytes(UsedOPKMarkID));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyRemoteIK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyRemoteIK = false;

      int elRemoteIK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elRemoteIK = ConvertBytesToByte(binaryCtx.buf);

      RemoteIK!.add(elRemoteIK);
    }

    if (isEmptyRemoteIK) {
      RemoteIK = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyRemoteEK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyRemoteEK = false;

      int elRemoteEK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elRemoteEK = ConvertBytesToByte(binaryCtx.buf);

      RemoteEK!.add(elRemoteEK);
    }

    if (isEmptyRemoteEK) {
      RemoteEK = null;
    }
  }
}

class SendInitMessagePMRequest implements Message {
  List<int>? SessionToken;

  List<int>? ReceiverIK;

  List<int>? SelfEK;

  int UsedOPKMarkID;

  SendInitMessagePMRequest({
    required this.SessionToken,
    required this.ReceiverIK,
    required this.SelfEK,
    required this.UsedOPKMarkID,
  });

  SendInitMessagePMRequest Copy() => SendInitMessagePMRequest(
      SessionToken: List.filled(0, 0xff, growable: true),
      ReceiverIK: List.filled(0, 0xff, growable: true),
      SelfEK: List.filled(0, 0xff, growable: true),
      UsedOPKMarkID: 0);

  static SendInitMessagePMRequest fromBytes(Uint8List bytes) => SendInitMessagePMRequest(
      SessionToken: List.filled(0, 0xff, growable: true),
      ReceiverIK: List.filled(0, 0xff, growable: true),
      SelfEK: List.filled(0, 0xff, growable: true),
      UsedOPKMarkID: 0)
    ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    List<int> arrBufReceiverIK = [];
    for (var elReceiverIK in ReceiverIK!) {
      arrBufReceiverIK.addAll(ConvertByteToBytes(elReceiverIK));
    }
    b.addAll(ConvertSizeToBytes(arrBufReceiverIK.length));
    b.addAll(arrBufReceiverIK);
    List<int> arrBufSelfEK = [];
    for (var elSelfEK in SelfEK!) {
      arrBufSelfEK.addAll(ConvertByteToBytes(elSelfEK));
    }
    b.addAll(ConvertSizeToBytes(arrBufSelfEK.length));
    b.addAll(arrBufSelfEK);
    b.addAll(ConvertIntToBytes(UsedOPKMarkID));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptyReceiverIK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptyReceiverIK = false;

      int elReceiverIK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elReceiverIK = ConvertBytesToByte(binaryCtx.buf);

      ReceiverIK!.add(elReceiverIK);
    }

    if (isEmptyReceiverIK) {
      ReceiverIK = null;
    }

    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySelfEK = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySelfEK = false;

      int elSelfEK;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSelfEK = ConvertBytesToByte(binaryCtx.buf);

      SelfEK!.add(elSelfEK);
    }

    if (isEmptySelfEK) {
      SelfEK = null;
    }
  }
}

class SendInitMessagePMResponse implements Message {
  SendInitMessagePMResponse();

  SendInitMessagePMResponse Copy() => SendInitMessagePMResponse();

  static SendInitMessagePMResponse fromBytes(Uint8List bytes) =>
      SendInitMessagePMResponse()..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
  }
}

class ListenUpdatesReq implements Message {
  List<int>? SessionToken;

  int MonotonicIdOffset;

  ListenUpdatesReq({
    required this.SessionToken,
    required this.MonotonicIdOffset,
  });

  ListenUpdatesReq Copy() => ListenUpdatesReq(SessionToken: List.filled(0, 0xff, growable: true), MonotonicIdOffset: 0);

  static ListenUpdatesReq fromBytes(Uint8List bytes) =>
      ListenUpdatesReq(SessionToken: List.filled(0, 0xff, growable: true), MonotonicIdOffset: 0)
        ..Unmarshal(BinaryIterator(bytes));

  Uint8List Marshal() {
    List<int> b = [];

    List<int> size = ConvertSizeToBytes(0);
    b.addAll(size);
    List<int> arrBufSessionToken = [];
    for (var elSessionToken in SessionToken!) {
      arrBufSessionToken.addAll(ConvertByteToBytes(elSessionToken));
    }
    b.addAll(ConvertSizeToBytes(arrBufSessionToken.length));
    b.addAll(arrBufSessionToken);
    b.addAll(ConvertIntToBytes(MonotonicIdOffset));
    size = ConvertSizeToBytes(b.length - size.length);
    for (int i = 0; i < size.length; i++) {
      b[i] = size[i];
    }

    return Uint8List.fromList(b);
  }

  void Unmarshal(BinaryIterator b) {
    BinaryCtx binaryCtx = BinaryCtx();
    binaryCtx.size = b.nextSize();

    binaryCtx.arrBuf = b.slice(binaryCtx.size);
    binaryCtx.pos = 0;

    bool isEmptySessionToken = true;

    while (binaryCtx.arrBuf.hasNext()) {
      isEmptySessionToken = false;

      int elSessionToken;

      binaryCtx.buf = binaryCtx.arrBuf.slice(1);
      elSessionToken = ConvertBytesToByte(binaryCtx.buf);

      SessionToken!.add(elSessionToken);
    }

    if (isEmptySessionToken) {
      SessionToken = null;
    }
  }
}
