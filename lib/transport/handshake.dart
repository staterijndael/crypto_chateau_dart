import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/dh/dh.dart';
import 'package:crypto_chateau_dart/dh/params.dart';

import 'conn_bloc.dart';

enum HandshakeSteps {
  Ready,
  ReadInitMsg,
  GetDhParams,
  SendClientPublicKey,
  GetServerPublicKey,
  Finished,
}

class TcpBlocHandshake {
  HandshakeSteps? _currentStep;
  TcpBloc? _tcpBloc;
  KeyStore? keyStore;

  TcpBlocHandshake({required TcpBloc tcpBloc}) {
    _currentStep = HandshakeSteps.Ready;
    tcpBloc = tcpBloc;
    keyStore = KeyStore();
  }

  handshake(Iterable<int> message) async* {
    switch (_currentStep) {
      case HandshakeSteps.Ready:
        _currentStep = HandshakeSteps.ReadInitMsg;
        return;
      case HandshakeSteps.ReadInitMsg:
        _tcpBloc!.add(SendMessage(message: Uint8List.fromList("handshake".codeUnits)));
        return;
      case HandshakeSteps.GetDhParams:
        List<Uint8List> dhParams = parseMsg(message, 2);
        if (dhParams.length != 2) {
          throw "incorrect count of diffie-hellman key exchange init params";
        }

        BigInt generatorParam = byteArrayToBigInt(dhParams[0]);
        BigInt primeParam = byteArrayToBigInt(dhParams[1]);

        if (generatorParam != Generator || primeParam != Prime) {
          throw "incorrect values of params for diffie-hellman key exchange";
        }

        keyStore!.GeneratePrivateKey();
        keyStore!.GeneratePublicKey();

        _currentStep = HandshakeSteps.SendClientPublicKey;
        yield* handshake(message);
        return;
      case HandshakeSteps.SendClientPublicKey:
        Uint8List publicKeyBytes = bigIntToByteArray(keyStore!.publicKey);
        _tcpBloc!.add(SendMessage(message: publicKeyBytes));
        return;
      case HandshakeSteps.GetServerPublicKey:
        List<Uint8List> serverPublicKeyBytes = parseMsg(message, 1);
        BigInt serverPublicKey = byteArrayToBigInt(serverPublicKeyBytes[0]);
        keyStore!.GenerateSharedKey(receivedPublicKey: serverPublicKey);

        _currentStep = HandshakeSteps.Finished;
        return;
      case HandshakeSteps.Finished:
        throw "handshake already finished";
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
  var lastIndex = -1;

  var currentResultIndex = 0;
  var currentBufIndex = 0;

  var delimSymb = utf8.encode("|")[0];

  var currentIndex = 0;

  for (final symb in msg) {
    if (symb == delimSymb) {
      if (lastIndex + 1 == currentIndex) {
        throw "incorrect message format";
      }

      if (currentResultIndex >= result.length) {
        throw "incorrect params count";
      }

      result[currentResultIndex] =
          buf.sublist(lastIndex + 1, currentBufIndex + 1);
      currentResultIndex++;

      lastIndex = currentIndex;
    }

    buf[currentBufIndex] = symb;
    currentBufIndex++;
    currentIndex++;
  }

  if (lastIndex == buf.length - 1) {
    throw "incorrect message format";
  }

  result[currentResultIndex] = buf.sublist(lastIndex + 1, currentBufIndex + 1);
  currentResultIndex++;

  return result;
}
