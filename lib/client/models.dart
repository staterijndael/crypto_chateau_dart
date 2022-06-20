import 'dart:typed_data';

abstract class Request {
  Uint8List Marshal();
}

class GetUserRequest extends Request {
  final int userID;

  GetUserRequest({required this.userID});

  Uint8List Marshal() {
    var buffer = Uint8List(8).buffer;
    var bdata = ByteData.view(buffer);
    bdata.setUint64(0, userID);

    var bDataArr =
        bdata.buffer.asUint8List(bdata.offsetInBytes, bdata.lengthInBytes);

    String marshalStr = "GetUserRequest# UserID: $bDataArr";

    Uint8List data = Uint8List.fromList(marshalStr.codeUnits);

    return data;
  }
}

abstract class Response {
  Unmarshal(Map<String, Uint8List> params);
}

class GetUserResponse extends Response {
  String? userName;

  GetUserResponse([String? userName]) {
    this.userName = userName!;
  }

  Unmarshal(Map<String, Uint8List> params) {
    userName = String.fromCharCodes(params["UserName"]!);
  }
}
