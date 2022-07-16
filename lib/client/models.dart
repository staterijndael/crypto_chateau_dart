import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/client/response.dart';

abstract class Message {
  Uint8List Marshal();
  Unmarshal(Map<String, Uint8List> params);
}

class User extends Message {
  int? id;
  String? nickname;
  int? age;
  bool? gender;
  String? status;

  User({this.id, this.nickname, this.age, this.gender, this.status});

  Uint8List Marshal() {
    var idConvertedBytes = ByteData.view(Uint8List(8).buffer);
    idConvertedBytes.setUint64(0, id!);

    var ageConvertedBytes = ByteData.view(Uint8List(8).buffer);
    ageConvertedBytes.setUint64(0, id!);

    int convertedGender = 0;

    if (gender == true) {
      convertedGender = 1;
    }

    List<int> data = List.from("(Id:".codeUnits)
      ..addAll(idConvertedBytes.buffer.asUint8List(
          idConvertedBytes.offsetInBytes, idConvertedBytes.lengthInBytes))
      ..addAll(",nickname:\"$nickname\",age:".codeUnits)
      ..addAll(ageConvertedBytes.buffer.asUint8List(
          ageConvertedBytes.offsetInBytes, ageConvertedBytes.lengthInBytes))
      ..addAll(",gender:".codeUnits)
      ..add(convertedGender)
      ..addAll(",status:\"$status\"".codeUnits);

    return Uint8List.fromList(data);
  }

  Unmarshal(Map<String, Uint8List> params) {
    var idBytes = ByteData.view(params["Id"]!.buffer);
    id = idBytes.getUint64(0);

    var ageBytes = ByteData.view(params["Age"]!.buffer);
    age = ageBytes.getUint64(0);

    if (params["Gender"]![0] == 1) {
      gender = true;
    } else {
      gender = false;
    }

    nickname = utf8.decode(params["Nickname"]!);
    status = utf8.decode(params["Status"]!);
  }
}

class GetUserRequest extends Message {
  int? userID;

  GetUserRequest({this.userID});

  Uint8List Marshal() {
    var bdata = ByteData.view(Uint8List(8).buffer);
    bdata.setUint64(0, userID!);

    Uint8List bDataArr =
        bdata.buffer.asUint8List(bdata.offsetInBytes, bdata.lengthInBytes);

    List<int> data = List.from("GetUser# UserID: ".codeUnits)
      ..addAll(
          bdata.buffer.asUint8List(bdata.offsetInBytes, bdata.lengthInBytes));
    return Uint8List.fromList(data);
  }

  Unmarshal(Map<String, Uint8List> params) {}
}

class GetUserResponse extends Message {
  User user = User();

  GetUserResponse([User? user]) {
    if (user != null) {
      this.user = user;
    }
  }

  Unmarshal(Map<String, Uint8List> params) {
    Map<String, Uint8List> userParams = getParams(params["User"]!);
    user.Unmarshal(userParams);
  }

  Uint8List Marshal() {
    return Uint8List(0);
  }
}

class SendCodeRequest extends Message {
  String? number;
  String? passHash;

  SendCodeRequest({this.number, this.passHash});

  Unmarshal(Map<String, Uint8List> params) {
    number = utf8.decode(params["Number"]!);
    passHash = utf8.decode(params["PassHash"]!);
  }

  Uint8List Marshal() {
    List<int> data = "SendCode# Number:$number,PassHash:$passHash".codeUnits;
    return Uint8List.fromList(data);
  }
}

class SendCodeResponse extends Message {
  Uint8List Marshal() {
    return Uint8List(0);
  }

  Unmarshal(Map<String, Uint8List> params) {
    return;
  }
}

// streams
class ListenUpdatesSend {}

class ListenUpdatesGet {
  String eventType;
  String eventBody;

  ListenUpdatesGet({required this.eventBody, required this.eventType});
}
