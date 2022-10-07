import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:x25519/x25519.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

import 'conn_bloc.dart';

enum HandshakeSteps {
  Ready,
  SendInitMsg,
  SendClientPublicKey,
  GetServerPublicKey,
  GetSuccessMsg,
  Served,
}

class TcpBlocHandshake {
  HandshakeSteps? _currentStep;
  TcpBloc? tcpBloc;
  KeyPair? ecdhKeyPair;
  Uint8List? sharedKey;
  TcpBlocHandshake({required this.tcpBloc}) {
    _currentStep = HandshakeSteps.Ready;
  }

  handshake(Iterable<int> message) {
    switch (_currentStep) {
      case HandshakeSteps.Ready:
        ecdhKeyPair = generateKeyPair();

        _currentStep = HandshakeSteps.SendInitMsg;
        handshake(Uint8List(0));
        return;
      case HandshakeSteps.SendInitMsg:
        tcpBloc!.sendMessage(
            SendMessage(message: Uint8List.fromList("handshake".codeUnits)));
        _currentStep = HandshakeSteps.GetServerPublicKey;
        return;
      case HandshakeSteps.GetServerPublicKey:
        List<Uint8List> serverPublicKeyBytes = parseMsg(message, 1);
        Uint8List serverPublicKey = serverPublicKeyBytes[0];
        sharedKey = X25519(ecdhKeyPair!.privateKey, serverPublicKey);

        _currentStep = HandshakeSteps.SendClientPublicKey;
        handshake(Uint8List(0));
        return;
      case HandshakeSteps.SendClientPublicKey:
        tcpBloc!.sendMessage(SendMessage(message: Uint8List.fromList(ecdhKeyPair!.publicKey)));
        _currentStep = HandshakeSteps.GetSuccessMsg;
        return;
      case HandshakeSteps.GetSuccessMsg:
        if (message.elementAt(0) != utf8.encode('1')[0]) {
          throw "message is not success";
        }
        _currentStep = HandshakeSteps.Served;
        return;
      case HandshakeSteps.Served:
        throw "handshake already served";
    }
  }

  HandshakeSteps getCurrentStep() {
    return _currentStep!;
  }
}

List<Uint8List> parseMsg(Iterable<int> msg, int paramsNum) {
  if (msg.isEmpty) {
    throw "empty message";
  }
  List<Uint8List> result = List.filled(paramsNum, Uint8List(0));

  Uint8List buf = Uint8List(msg.length);
  var lastIndex = 0;

  var currentResultIndex = 0;

  Uint8List convertedMsg = msg as Uint8List;

  while (msg.length - 1 > lastIndex) {
    if (msg.length - 1 - lastIndex < 2) {
      if (kDebugMode) {
        print("incorrect data length");
      }
      break;
    }

    int messageLength = msg[lastIndex] | msg[lastIndex + 1] << 8;

    int startIndex = lastIndex + 2;

    Uint8List message = msg.sublist(startIndex, startIndex + messageLength);
    result[currentResultIndex] = message;
    currentResultIndex++;

    lastIndex = startIndex + messageLength;
  }

  return result;
}
