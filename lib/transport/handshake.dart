import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/dh/dh.dart';
import 'package:crypto_chateau_dart/dh/params.dart';
import 'package:flutter/foundation.dart';

import 'conn_bloc.dart';

enum HandshakeSteps {
  Ready,
  SendInitMsg,
  GetDhParams,
  SendClientPublicKey,
  GetServerPublicKey,
  GetSuccessMsg,
  Served,
}

class TcpBlocHandshake {
  HandshakeSteps? _currentStep;
  TcpBloc? tcpBloc;
  KeyStore? keyStore;

  TcpBlocHandshake({required this.tcpBloc, required this.keyStore}) {
    _currentStep = HandshakeSteps.Ready;
  }

  handshake(Iterable<int> message) {
    switch (_currentStep) {
      case HandshakeSteps.Ready:
        if (!keyStore!.IsKeyValid(keyStore!.privateKey)) {
          throw "incorrect private key during initializing";
        }
        if (!keyStore!.IsKeyValid(keyStore!.publicKey)) {
          throw "incorrect public key during initializing";
        }

        _currentStep = HandshakeSteps.SendInitMsg;
        return;
      case HandshakeSteps.SendInitMsg:
        tcpBloc!.sendMessage(
            SendMessage(message: Uint8List.fromList("handshake".codeUnits)));
        _currentStep = HandshakeSteps.GetDhParams;
        return;
      case HandshakeSteps.GetDhParams:
        List<Uint8List> dhParams = parseMsg(message, 2);
        if (dhParams.length != 2) {
          throw "incorrect count of diffie-hellman key exchange init params";
        }

        BigInt generatorParam = byteArrayToBigInt(dhParams[0]);
        Uint8List primeHashParam = dhParams[1];

        if (generatorParam != Generator || primeHashParam != PrimeHash) {
          throw "incorrect values of params for diffie-hellman key exchange";
        }

        _currentStep = HandshakeSteps.GetServerPublicKey;
        return;
      case HandshakeSteps.GetServerPublicKey:
        List<Uint8List> serverPublicKeyBytes = parseMsg(message, 1);
        BigInt serverPublicKey = byteArrayToBigInt(serverPublicKeyBytes[0]);
        keyStore!.GenerateSharedKey(receivedPublicKey: serverPublicKey);

        _currentStep = HandshakeSteps.SendClientPublicKey;
        handshake(Uint8List(0));
        return;
      case HandshakeSteps.SendClientPublicKey:
        Uint8List publicKeyBytes = bigIntToByteArray(keyStore!.publicKey);
        tcpBloc!.sendMessage(SendMessage(message: publicKeyBytes));
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
