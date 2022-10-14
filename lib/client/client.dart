import 'dart:async';
import 'dart:convert';

import 'package:crypto_chateau_dart/client/conv.dart';
import 'package:crypto_chateau_dart/client/models.dart';
import 'package:crypto_chateau_dart/transport/conn_bloc.dart';
import 'package:flutter/foundation.dart';

class InternalClient {
  String host;
  int port;
  bool isEncryptionEnabled;

  InternalClient(
      {required this.host,
      required this.port,
      required this.isEncryptionEnabled});

  Future<Uint8List> handleMessage(String handlerName, Uint8List data) async {
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
            host: host, port: port, encryptionEnabled: isEncryptionEnabled));

    var firstValueReceived = Completer<Uint8List>();

    responseStream.listen((event) {
      if (!firstValueReceived.isCompleted) {
        firstValueReceived.complete(event);
      }
    });

    Uint8List rawResponse = await firstValueReceived.future;

    int lastMethodNameIndex = getLastMethodNameIndex(rawResponse);
    String methodName =
        String.fromCharCodes(rawResponse.sublist(0, lastMethodNameIndex));
    if (handlerName != methodName) {
      throw "incorrect handler name";
    }

    Uint8List body = rawResponse.sublist(lastMethodNameIndex + 1);

    tcpBloc.close();

    return body;
  }

  Future<void Function(SendMessage msg)> listenUpdates<T>(
      String handlerName,
      void Function() onEncryptEnabled,
      T respType,
      void Function(T msg) onGotMessage,
      Message initMessage) async {
    TcpBloc tcpBloc = TcpBloc();
    StreamController streamController = StreamController();

    onEncryptEnabled() {
      Uint8List decoratedMsg =
          decorateRawDataByHandlerName(handlerName, initMessage.Marshal());
      tcpBloc.sendMessage(SendMessage(message: decoratedMsg));

      onEncryptEnabled();

      streamController.stream.listen((event) async {
        var futureValueReceived = Completer<Uint8List>();
        futureValueReceived.complete(event);

        Uint8List gotMessage = await futureValueReceived.future;

        int lastMethodNameIndex = getLastMethodNameIndex(gotMessage);
        String methodName =
            String.fromCharCodes(gotMessage.sublist(0, lastMethodNameIndex));
        if (handlerName != methodName) {
          throw "incorrect handler name";
        }

        Uint8List body = gotMessage.sublist(lastMethodNameIndex + 1);

        Map<String, Uint8List> params = GetParams(body)[1];
        (respType as Message).Unmarshal(params);

        onGotMessage(respType);
      });
    }

    onSendMessage(SendMessage msg) {
      tcpBloc.sendMessage(msg);
    }

    tcpBloc.connect(
        onEncryptEnabled,
        streamController,
        Connect(
            host: host, port: port, encryptionEnabled: isEncryptionEnabled));

    return onSendMessage;
  }
}

Uint8List decorateRawDataByHandlerName(String handlerName, Uint8List data) {
  Uint8List decoratedRawData =
      Uint8List(handlerName.codeUnits.length + data.length + 1);

  for (int i = 0; i < handlerName.codeUnits.length; i++) {
    decoratedRawData[i] = handlerName.codeUnits[i];
  }
  decoratedRawData[handlerName.codeUnits.length] = utf8.encode('#')[0];
  for (int i = handlerName.codeUnits.length + 1;
      i < handlerName.codeUnits.length + 1 + data.length;
      i++) {
    decoratedRawData[i] = data[i - handlerName.codeUnits.length - 1];
  }

  return decoratedRawData;
}

int getLastMethodNameIndex(Uint8List data) {
  int finalIndex = 0;

  for (var i = 0; i < data.length; i++) {
    if (data[i] == utf8.encode('#')[0]) {
      finalIndex = i;
    }
  }

  return finalIndex;
}
