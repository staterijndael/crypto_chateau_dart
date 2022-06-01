import 'dart:typed_data';

import 'package:crypto_chateau_dart/client/response.dart';

import '../transport/conn_bloc.dart';
import 'models.dart';

class Client {
  TcpBloc? _tcpBloc;
  final Map<String, Uint8List> _waitResponsesMap = {};

  int maxTimerDifference = 5000;

  Client(
      {required String host,
      required int port,
      required bool isEncryptionEnabled}) {
    _tcpBloc = TcpBloc(readFunc: handleFunc);
    _tcpBloc!.add(Connect(
        host: host, port: port, encryptionEnabled: isEncryptionEnabled));
  }

  void handleFunc(Uint8List data) {
    int lastMethodNameIndex = getLastMethodNameIndex(data);
    String methodName =
        String.fromCharCodes(data.sublist(0, lastMethodNameIndex));

    _waitResponsesMap[methodName] = data.sublist(lastMethodNameIndex + 1);
  }

  //handlers
  GetUserResponse GetUser(GetUserRequest request) {
    _tcpBloc!.add(SendMessage(message: request.Marshal()));
    Uint8List rawResponse =
        WaitResponse(_waitResponsesMap, "GetUser", maxTimerDifference);
    GetUserResponse response =
        GetResponse("GetUser", rawResponse) as GetUserResponse;
    return response;
  }
}

int getLastMethodNameIndex(Uint8List data) {
  int finalIndex = 0;

  for (var i = 0; i < data.length; i++) {
    if (data[i] == Uint8List.fromList("#".codeUnits)[0]) {
      finalIndex = i;
    }
  }

  return finalIndex;
}
