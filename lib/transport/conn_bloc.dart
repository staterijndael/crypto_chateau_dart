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
      handleReceivedMessage(MessageReceived(
        message: event,
      ));
    });
    _socket!.handleError(() {
      handleError(ErrorOccured(errMessage: "socket error"));
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
      if (tcpBlocHandshake!.getCurrentStep() == HandshakeSteps.Finished) {
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

      _socket!.writeln(message);
    }
  }

  @override
  Future<void> close() async {
    await _socketStreamSub?.cancel();
    await _socket?.close();
  }
}
