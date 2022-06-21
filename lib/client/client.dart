import 'dart:typed_data';
import 'dart:ui';

import 'package:crypto_chateau_dart/client/response.dart';

import '../transport/conn_bloc.dart';
import 'models.dart';

class ClientController {
  late VoidCallback onEncryptionEnabled;
  late VoidCallback onClientConnected;
  late void Function(Response) onEndpointMessageReceived;

  ClientController(
      {required this.onEncryptionEnabled,
      required this.onEndpointMessageReceived,
      required this.onClientConnected});
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
  ClientController clientController;
  ConnectParams connectParams;

  Client({required this.clientController, required this.connectParams});

  void onEndpointMessageReceived(TcpBloc tcpBloc, Uint8List data) {
    tcpBloc.close();

    int lastMethodNameIndex = getLastMethodNameIndex(data);
    String methodName =
        String.fromCharCodes(data.sublist(0, lastMethodNameIndex));

    Uint8List body = data.sublist(lastMethodNameIndex + 1);
    Response response = GetResponse(methodName, body);
    clientController.onEndpointMessageReceived(response);
  }

  void onEncryptionEnabled() {
    clientController.onEncryptionEnabled();
  }

  //handlers
  GetUser(GetUserRequest request) async {
    TcpBloc tcpBloc = TcpBloc();

    onEncryptEnabled() {
      tcpBloc.sendMessage(SendMessage(message: request.Marshal()));
    }

    TcpController tcpController = TcpController(
        onEncryptionEnabled: onEncryptEnabled,
        onEndpointMessageReceived: onEndpointMessageReceived);

    tcpBloc.connect(
        tcpController,
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
