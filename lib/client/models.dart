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
}

class GetUserResponse extends Response{
  final String userName;

  GetUserResponse({required this.userName});
}