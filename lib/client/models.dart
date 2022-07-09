import 'dart:typed_data';

abstract class Request {
  Uint8List Marshal();
}

class GetUserRequest extends Request {
  final int userID;

  GetUserRequest({required this.userID});

  Uint8List Marshal() {
    var bdata = ByteData.view(Uint8List(8).buffer);
    bdata.setUint64(0, userID);

    Uint8List bDataArr =
        bdata.buffer.asUint8List(bdata.offsetInBytes, bdata.lengthInBytes);

    List<int> data = List.from("GetUser# UserID: ".codeUnits)
      ..addAll(
          bdata.buffer.asUint8List(bdata.offsetInBytes, bdata.lengthInBytes));
    return Uint8List.fromList(data);
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

// streams
class ListenUpdatesSend {}

class ListenUpdatesGet {
  String eventType;
  String eventBody;

  ListenUpdatesGet({required this.eventBody, required this.eventType});
}
