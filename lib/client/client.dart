import 'dart:async';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/client/response.dart';

import '../transport/conn_bloc.dart';
import 'models.dart';

class ClientController {
  ClientController();
}

class ConnectParams {
  String host;
  int port;
  bool isEncryptionEnabled;

  ConnectParams(
      {required this.host,
      required this.port,
      required this.isEncryptionEnabled});
}

class Client {
  ConnectParams connectParams;

  Client({required this.connectParams});

  //handlers
  Future<SendCodeResponse> SendCode(SendCodeRequest request) async {
    return await handleMessage(request.Marshal()) as SendCodeResponse;
  }

  Future<RegisterResponse> Register(RegisterRequest request) async {
    return await handleMessage(request.Marshal()) as RegisterResponse;
  }

  Future<HandleCodeResponse> HandleCode(HandleCodeRequest request) async {
    return await handleMessage(request.Marshal()) as HandleCodeResponse;
  }

  Future<AuthTokenResponse> AuthToken(AuthTokenRequest request) async {
    return await handleMessage(request.Marshal()) as AuthTokenResponse;
  }

  Future<AuthCredentialsResponse> AuthCreds(
      AuthCredentialsRequest request) async {
    return await handleMessage(request.Marshal()) as AuthCredentialsResponse;
  }

  Future<FindUsersByPartNicknameResponse> FindUsersByPartNickname(
      FindUsersByPartNicknameRequest request) async {
    return await handleMessage(request.Marshal())
        as FindUsersByPartNicknameResponse;
  }

  Future<GetInitMsgKeysResponse> GetInitMsgKeys(
      GetInitMsgKeysRequest request) async {
    return await handleMessage(request.Marshal()) as GetInitMsgKeysResponse;
  }

  Future<LoadOPKResponse> GetInitMsgKeys(LoadOPKRequest request) async {
    return await handleMessage(request.Marshal()) as LoadOPKResponse;
  }

  Future<RequiredOPKResponse> RequiredOPK(RequiredOPKRequest request) async {
    return await handleMessage(request.Marshal()) as RequiredOPKResponse;
  }

  Future<Message> handleMessage(Uint8List data) async {
    TcpBloc tcpBloc = TcpBloc();

    onEncryptEnabled() {
      tcpBloc.sendMessage(SendMessage(message: data));
    }

    StreamController streamController = StreamController();

    Stream responseStream = streamController.stream;

    tcpBloc.connect(
        onEncryptEnabled,
        streamController,
        Connect(
            host: connectParams.host,
            port: connectParams.port,
            encryptionEnabled: connectParams.isEncryptionEnabled));

    var firstValueReceived = Completer<Uint8List>();

    responseStream.listen((event) {
      if (!firstValueReceived.isCompleted) {
        firstValueReceived.complete(event);
      }
    });

    Uint8List rawResponse = await firstValueReceived.future;

    tcpBloc.close();

    return getResponse(rawResponse);
  }

  Message getResponse(Uint8List rawResponse) {
    int lastMethodNameIndex = getLastMethodNameIndex(rawResponse);
    String methodName =
        String.fromCharCodes(rawResponse.sublist(0, lastMethodNameIndex));

    Uint8List body = rawResponse.sublist(lastMethodNameIndex + 1);
    Message response = GetResponse(methodName, body);
    return response;
  }
  // SendCode(SendCodeRequest request) async {
  //   TcpBloc tcpBloc = TcpBloc();

  //   onEncryptEnabled() {
  //     tcpBloc.sendMessage(SendMessage(message: request.Marshal()));
  //   }

  //   TcpController tcpController = TcpController(
  //       onEncryptionEnabled: onEncryptEnabled,
  //       onEndpointMessageReceived: onEndpointMessageReceived);

  //   tcpBloc.connect(
  //       tcpController,
  //       Connect(
  //           host: connectParams.host,
  //           port: connectParams.port,
  //           encryptionEnabled: connectParams.isEncryptionEnabled));
  // }

  //streams

  void ListenUpdates() async {
    TcpBloc tcpBloc = TcpBloc();

    onEncryptEnabled() {}

    StreamController streamController = StreamController();

    tcpBloc.connect(
        onEncryptEnabled,
        streamController,
        Connect(
            host: connectParams.host,
            port: connectParams.port,
            encryptionEnabled: connectParams.isEncryptionEnabled));
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
