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

    Uint8List bDataArr =
        bdata.buffer.asUint8List(bdata.offsetInBytes, bdata.lengthInBytes);

    String marshalStr = "GetUser# UserID: ";
    List<int> MarshalStrBytes = marshalStr.codeUnits;

    Uint8List data = Uint8List(MarshalStrBytes.length + bDataArr.length);

    for (var i = 0; i < MarshalStrBytes.length; i++) {
      data[i] = MarshalStrBytes[i];
    }

    for (var i = 0; i < bDataArr.length; i++) {
      data[MarshalStrBytes.length + i] = bDataArr[i];
    }

    return data;
  }
}

abstract class Response {
  Unmarshal(Map<String, Uint8List> params);
}

class GetUserResponse extends Response {
  String? userName;

  GetUserResponse([String? userName]) {
    if (userName != null) {
      this.userName = userName;
    }
  }

  Unmarshal(Map<String, Uint8List> params) {
    userName = String.fromCharCodes(params["UserName"]!);
  }
}
