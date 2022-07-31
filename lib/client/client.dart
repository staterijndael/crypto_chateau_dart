import 'dart:async';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/client/response.dart';
import 'package:crypto_chateau_dart/dh/dh.dart';

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
  KeyStore keyStore = KeyStore();

  Client({required this.connectParams}) {
    keyStore.GeneratePrivateKey();
    keyStore.GeneratePublicKey();
  }

  //handlers
  Future<Message> SendCode(SendCodeRequest request) async {
    return handleMessage(request.Marshal());
  }

  Future<Message> Register(RegisterRequest request) async {
    return handleMessage(request.Marshal());
  }

  Future<Message> HandleCode(HandleCodeRequest request) async {
    return handleMessage(request.Marshal());
  }

  Future<Message> AuthToken(AuthTokenRequest request) async {
    return handleMessage(request.Marshal());
  }

  Future<Message> AuthCreds(AuthCredentialsRequest request) async {
    return handleMessage(request.Marshal());
  }

  handleMessage(Uint8List data) async {
    TcpBloc tcpBloc = TcpBloc(keyStore: keyStore);

    onEncryptEnabled() {
      tcpBloc.sendMessage(SendMessage(message: data));
    }

    Stream<Uint8List> responseStream = await tcpBloc.connect(
        onEncryptEnabled,
        Connect(
            host: connectParams.host,
            port: connectParams.port,
            encryptionEnabled: connectParams.isEncryptionEnabled));

    var firstValueReceived = Completer<Uint8List>();

    responseStream.listen((event) {
      if (!firstValueReceived.isCompleted) {
        firstValueReceived.complete();
      }
    });

    tcpBloc.close();

    return getResponse(await firstValueReceived.future);
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
    TcpBloc tcpBloc = TcpBloc(keyStore: keyStore);

    onEncryptEnabled() {}

    tcpBloc.connect(
        onEncryptEnabled,
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
