import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:crypto_chateau_dart/aes_256/aes_256.dart';
import 'package:crypto_chateau_dart/dh/params.dart';
import 'package:crypto_chateau_dart/transport/handshake.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

part 'conn_event.dart';

enum EncryptionState {
  Disabled,
  Enabling,
  Enabled,
}

class TcpBloc {
  Socket? _socket;
  StreamSubscription? _socketStreamSub;
  ConnectionTask<Socket>? _socketConnectionTask;
  void Function(Uint8List)? _readFunc;

  EncryptionState _encryptionState = EncryptionState.Disabled;
  Uint8List? _secretKey;
  TcpBlocHandshake? tcpBlocHandshake;

  TcpBloc({required void Function(Uint8List) readFunc}) : super() {
    _readFunc = readFunc;
  }

  Future<void> connect(Connect event) async {
    _socketConnectionTask = await Socket.startConnect(event.host, event.port);
    _socket = await _socketConnectionTask!.socket;

    _socketStreamSub = _socket!.asBroadcastStream().listen((event) {
      List<Uint8List> messages = separateMessages(event);

      for (var i = 0; i < messages.length; i++) {
        handleReceivedMessage(MessageReceived(
          message: messages[i],
        ));
      }
    });
    _socket!.handleError((err) {
      handleError(ErrorOccured(errMessage: "socket error $err"));
    });

    if (event.encryptionEnabled) {
      _encryptionState = EncryptionState.Enabling;
      tcpBlocHandshake = TcpBlocHandshake(tcpBloc: this);
      tcpBlocHandshake!.handshake(Uint8List(0));
    }
  }

  void disconnect(Disconnect event) async {
    try {
      _socketConnectionTask?.cancel();
      await _socketStreamSub?.cancel();
      await _socket?.close();
    } catch (ex) {
      print(ex);
    }
  }

  void handleError(ErrorOccured event) async {
    await _socketStreamSub?.cancel();
    await _socket?.close();

    throw event.errMessage!;
  }

  void handleReceivedMessage(MessageReceived event) async {
    if (_encryptionState == EncryptionState.Enabling) {
      tcpBlocHandshake!.handshake(event.message);
      if (tcpBlocHandshake!.getCurrentStep() == HandshakeSteps.Served) {
        enableEncryption(
            EnableEncryption(sharedKey: tcpBlocHandshake!.keyStore!.sharedKey));
      }
    } else if (_encryptionState == EncryptionState.Enabled) {
      Uint8List decryptedData = Decrypt(event.message, _secretKey!);
      _readFunc!(decryptedData);
    } else {
      _readFunc!(event.message);
    }
  }

  void enableEncryption(EnableEncryption event) async {
    // maybe we should change only state
    Uint8List sharedKeyBytes = bigIntToByteArray(event.sharedKey);
    List<int> hash = sha256.convert(sharedKeyBytes).bytes;

    _secretKey = Uint8List.fromList(hash);
    _encryptionState = EncryptionState.Enabled;
  }

  void sendMessage(SendMessage event) async {
    if (_socket != null) {
      Uint8List message;
      if (_encryptionState == EncryptionState.Enabled) {
        message = Encrypt(event.message, _secretKey!);
      } else {
        message = event.message;
      }

      Uint8List messageWithLength = Uint8List(2 + message.length);
      messageWithLength[0] = message.length % 256;
      messageWithLength[1] = message.length ~/ 256;

      for (var i = 0; i < message.length; i++) {
        messageWithLength[i + 2] = message[i];
      }

      _socket!.writeln(messageWithLength);
    }
  }

  EncryptionState getEncryptionState() {
    return _encryptionState;
  }

  @override
  Future<void> close() async {
    await _socketStreamSub?.cancel();
    await _socket?.close();
  }
}

List<Uint8List> separateMessages(Uint8List data) {
  int lastIndex = 0;
  List<Uint8List> messages = <Uint8List>[];

  while (data.length - 1 > lastIndex) {
    if (data.length - 1 - lastIndex < 2) {
      if (kDebugMode) {
        print("incorrect data length");
      }
      break;
    }

    int messageLength = data[lastIndex] | data[lastIndex + 1] << 8;

    int startIndex = lastIndex + 2;

    Uint8List message = data.sublist(startIndex, startIndex + messageLength);
    messages.add(message);

    lastIndex = startIndex + messageLength;
  }

  return messages;
}
