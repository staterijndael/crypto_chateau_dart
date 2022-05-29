part of 'conn_bloc.dart';

enum SocketConnectionState {
  Connecting,
  Disconnecting,
  Connected,
  Failed,
  None
}

@immutable
class TcpState {
  final SocketConnectionState connectionState;
  final List<Iterable<int>> messages;

  late bool encryptionEnabled;
  late Uint8List sharedHash;

  TcpState({
    required this.connectionState,
    required this.messages,
  }) {
    encryptionEnabled = false;
    sharedHash = Uint8List(0);
  }

  TcpState.encryptedConstuctor({
    required this.connectionState,
    required this.messages,
    required this.encryptionEnabled,
    required this.sharedHash,
  });

  factory TcpState.initial() {
    return TcpState(
        connectionState: SocketConnectionState.None,
        messages: const <Iterable<int>>[]);
  }

  TcpState changeState({
    required SocketConnectionState connectionState,
  }) {
    return TcpState(
      connectionState: connectionState,
      messages: messages,
    );
  }

  TcpState addMessage({required Iterable<int> message}) {
    messages.add(message);

    return TcpState(
      connectionState: connectionState,
      messages: messages,
    );
  }

  TcpState enableEncryption({required Uint8List sharedHash}) {
    return TcpState.encryptedConstuctor(
      connectionState: connectionState,
      messages: messages,
      encryptionEnabled: true,
      sharedHash: sharedHash,
    );
  }
}
