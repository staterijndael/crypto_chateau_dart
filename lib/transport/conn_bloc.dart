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
part 'conn_state.dart';

enum EncryptionState{
  Disabled,
  Enabling,
  Enabled,
}

class TcpBloc extends Bloc<TcpEvent, TcpState> {
  Socket? _socket;
  StreamSubscription? _socketStreamSub;
  ConnectionTask<Socket>? _socketConnectionTask;
  void Function(Uint8List)? _readFunc;

  EncryptionState _encryptionState = EncryptionState.Disabled;
  Uint8List? _secretKey;
  TcpBlocHandshake? tcpBlocHandshake;


  TcpBloc({required void Function(Uint8List) readFunc, bool? encryptionEnabled})
      : super(TcpState.initial()){
        if (encryptionEnabled != null && encryptionEnabled){
          _encryptionState = EncryptionState.Enabling;
          tcpBlocHandshake = TcpBlocHandshake(tcpBloc: this);
          tcpBlocHandshake!.handshake(Uint8List(0));
        }
      }

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
      yield* _mapReceivedToState(event);
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
        add(MessageReceived(
          message: event,
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

  Stream<TcpState> _mapReceivedToState(MessageReceived event) async* {
    if (_encryptionState == EncryptionState.Enabling){
      tcpBlocHandshake!.handshake(event.message);
      if (tcpBlocHandshake!.getCurrentStep() == HandshakeSteps.Finished){
        yield* _mapEnableEncryptionToState(EnableEncryption(sharedKey: tcpBlocHandshake!.keyStore!.sharedKey));
      }
    }else if (_encryptionState == EncryptionState.Enabled){
        Uint8List decryptedData = Decrypt(event.message, _secretKey!);
        _readFunc!(decryptedData);
    }else{
      _readFunc!(event.message);
    }
  }

  Stream<TcpState> _mapSendMessageToState(SendMessage event) async* {
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

  Stream<TcpState> _mapEnableEncryptionToState(EnableEncryption event) async* {
    Uint8List sharedKeyBytes = bigIntToByteArray(event.sharedKey);
    List<int> hash = sha256.convert(sharedKeyBytes).bytes;

    _secretKey = Uint8List.fromList(hash);
    _encryptionState = EncryptionState.Enabled;
  }

  @override
  Future<void> close() {
    _socketStreamSub?.cancel();
    _socket?.close();
    return super.close();
  }
}
