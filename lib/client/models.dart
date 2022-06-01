import 'dart:typed_data';

abstract class Request{
  Uint8List Marshal();
}

class GetUserRequest extends Request{
  final int userID;

  GetUserRequest({required this.userID});

  Uint8List Marshal(){
    String marshalStr = "GetUserRequest# UserID: $userID";

    Uint8List data = Uint8List.fromList(marshalStr.codeUnits);

    return data;
  }
}

abstract class Response{
  Unmarshal(Map<String, Uint8List> params);
}

class GetUserResponse extends Response{
  String? userName;

  GetUserResponse([String? userName]){
    this.userName = userName!;
  }

  Unmarshal(Map<String, Uint8List> params){
      userName = String.fromCharCodes(params["UserName"]!);
  }
}