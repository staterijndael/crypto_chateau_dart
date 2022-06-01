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

enum EncryptionState {
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

  TcpBloc({required void Function(Uint8List) readFunc})
      : super(TcpState.initial()) {
    on<Connect>(_mapConnectToState);
    on<Disconnect>(_mapDisconnectToState);
    on<ErrorOccured>(_mapErrorToState);
    on<MessageReceived>(_mapReceivedToState);
    on<SendMessage>(_mapSendMessageToState);
    on<EnableEncryption>(_mapEnableEncryptionToState);
  }

  Stream<TcpState> _mapConnectToState(
      Connect event, Emitter<TcpState> emit) async* {
    emit(state.changeState(connectionState: SocketConnectionState.Connecting));
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

      if (event.encryptionEnabled) {
        _encryptionState = EncryptionState.Enabling;
        tcpBlocHandshake = TcpBlocHandshake(tcpBloc: this);
        tcpBlocHandshake!.handshake(Uint8List(0));
      }

      emit(state.changeState(connectionState: SocketConnectionState.Connected));
    } catch (err) {
      emit(state.changeState(connectionState: SocketConnectionState.Failed));
    }
  }

  Stream<TcpState> _mapDisconnectToState(
      Disconnect event, Emitter<TcpState> emit) async* {
    try {
      emit(state.changeState(
          connectionState: SocketConnectionState.Disconnecting));
      _socketConnectionTask?.cancel();
      await _socketStreamSub?.cancel();
      await _socket?.close();
    } catch (ex) {
      print(ex);
    }
    emit(state.changeState(connectionState: SocketConnectionState.None));
  }

  Stream<TcpState> _mapErrorToState(
      ErrorOccured event, Emitter<TcpState> emit) async* {
    emit(state.changeState(connectionState: SocketConnectionState.Failed));
    await _socketStreamSub?.cancel();
    await _socket?.close();
  }

  Stream<TcpState> _mapReceivedToState(
      MessageReceived event, Emitter<TcpState> emit) async* {
    if (_encryptionState == EncryptionState.Enabling) {
      tcpBlocHandshake!.handshake(event.message);
      if (tcpBlocHandshake!.getCurrentStep() == HandshakeSteps.Finished) {
        yield* _mapEnableEncryptionToState(
            EnableEncryption(sharedKey: tcpBlocHandshake!.keyStore!.sharedKey),
            emit);
      }
    } else if (_encryptionState == EncryptionState.Enabled) {
      Uint8List decryptedData = Decrypt(event.message, _secretKey!);
      _readFunc!(decryptedData);
    } else {
      _readFunc!(event.message);
    }
  }

  Stream<TcpState> _mapSendMessageToState(
      SendMessage event, Emitter<TcpState> emit) async* {
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

  Stream<TcpState> _mapEnableEncryptionToState(
      EnableEncryption event, Emitter<TcpState> emit) async* {
    // maybe we should change only state
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
