import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:crypto_chateau_dart/aes_256/aes_256.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

part 'conn_event.dart';
part 'conn_state.dart';

class TcpBloc extends Bloc<TcpEvent, TcpState> {
  Socket? _socket;
  StreamSubscription? _socketStreamSub;
  ConnectionTask<Socket>? _socketConnectionTask;
  Function(Iterable<int>)? _readFunc;

  TcpBloc({required Function(Iterable<int>) readFunc})
      : super(TcpState.initial());

  @override
  Stream<TcpState> mapEventToState(
    TcpEvent event,
  ) async* {
    if (event is Connect) {
      yield* _mapConnectToState(event);
    } else if (event is Disconnect) {
      yield* _mapDisconnectToState();
    } else if (event is ErrorOccured) {
      yield* _mapErrorToState();
    } else if (event is MessageReceived) {
      yield* _readFunc!(event.message);
    } else if (event is SendMessage) {
      yield* _mapSendMessageToState(event);
    } else if (event is EnableEncryption) {
      yield* _mapEnableEncryptionToState(event);
    }
  }

  Stream<TcpState> _mapConnectToState(Connect event) async* {
    yield state.changeState(connectionState: SocketConnectionState.Connecting);
    try {
      _socketConnectionTask = await Socket.startConnect(event.host, event.port);
      _socket = await _socketConnectionTask!.socket;

      _socketStreamSub = _socket!.asBroadcastStream().listen((event) {
        Uint8List message;
        if (state.encryptionEnabled) {
          message = Decrypt(event, state.sharedHash);
        } else {
          message = event;
        }

        add(MessageReceived(
          message: message,
        ));
      });
      _socket!.handleError(() {
        add(ErrorOccured());
      });

      yield state.changeState(connectionState: SocketConnectionState.Connected);
    } catch (err) {
      yield state.changeState(connectionState: SocketConnectionState.Failed);
    }
  }

  Stream<TcpState> _mapDisconnectToState() async* {
    try {
      yield state.changeState(
          connectionState: SocketConnectionState.Disconnecting);
      _socketConnectionTask?.cancel();
      await _socketStreamSub?.cancel();
      await _socket?.close();
    } catch (ex) {
      print(ex);
    }
    yield state.changeState(connectionState: SocketConnectionState.None);
  }

  Stream<TcpState> _mapErrorToState() async* {
    yield state.changeState(connectionState: SocketConnectionState.Failed);
    await _socketStreamSub?.cancel();
    await _socket?.close();
  }

  Stream<TcpState> _mapSendMessageToState(SendMessage event) async* {
    if (_socket != null) {
      Uint8List message;
      if (state.encryptionEnabled) {
        message = Encrypt(event.message, state.sharedHash);
      } else {
        message = event.message;
      }

      _socket!.writeln(message);
    }
  }

  Stream<TcpState> _mapEnableEncryptionToState(EnableEncryption event) async* {
    if (event.shared.isEmpty) {
      throw "incorrect shared key";
    }

    List<int> hash = sha256.convert(event.shared).bytes;
    yield state.enableEncryption(sharedHash: Uint8List.fromList(hash));

    Function(Iterable<int>)? funcBefore = _readFunc;
    HandshakeSteps currentStep = HandshakeSteps.ReadInitMsg;

  
  }

  @override
  Future<void> close() {
    _socketStreamSub?.cancel();
    _socket?.close();
    return super.close();
  }
}
