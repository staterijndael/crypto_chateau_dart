import 'dart:typed_data';
import 'dart:ui';

import 'package:crypto_chateau_dart/client/response.dart';

import '../transport/conn_bloc.dart';
import 'models.dart';

enum ConnState {
  NotConnected,
  Connecting,
  Connected,
  Disconnected,
}

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
  final String host;
  final int port;
  final bool isEncryptionEnabled;

  ConnectParams(
      {required this.host,
      required this.port,
      required this.isEncryptionEnabled});
}

class Client {
  TcpBloc? _tcpBloc;
  TcpController? tcpController;
  ClientController clientController;
  ConnectParams connectParams;

  ConnState? connState;

  Client({required this.clientController, required this.connectParams}) {
    _tcpBloc = TcpBloc();
    tcpController = TcpController(
        onEncryptionEnabled: onEncryptionEnabled,
        onEndpointMessageReceived: onEndpointMessageReceived);
    connState = ConnState.NotConnected;
  }

  Future<void> _connect(
      {required String host,
      required int port,
      required bool isEncryptionEnabled}) async {
    connState = ConnState.Connecting;
    await _tcpBloc!.connect(
        tcpController!,
        Connect(
            host: host, port: port, encryptionEnabled: isEncryptionEnabled));
    connState = ConnState.Connected;
    clientController.onClientConnected();
  }

  void onEndpointMessageReceived(Uint8List data) {
    int lastMethodNameIndex = getLastMethodNameIndex(data);
    String methodName =
        String.fromCharCodes(data.sublist(0, lastMethodNameIndex));

    Uint8List body = data.sublist(lastMethodNameIndex + 1);
    Response response = GetResponse(methodName, body);
    clientController.onEndpointMessageReceived(response);
    closeTcpBloc();
  }

  void onEncryptionEnabled() {
    clientController!.onEncryptionEnabled();
  }

  //handlers
  GetUser(GetUserRequest request) async {
    await _connect(
        host: connectParams.host,
        port: connectParams.port,
        isEncryptionEnabled: connectParams.isEncryptionEnabled);
    _tcpBloc!.sendMessage(SendMessage(message: request.Marshal()));
  }

  void closeTcpBloc() {
    connState = ConnState.Disconnected;
    _tcpBloc!.close();
  }

  EncryptionState getEncryptionStatus() {
    return _tcpBloc!.getEncryptionState();
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
