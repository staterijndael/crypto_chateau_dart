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

  const TcpState({
    required this.connectionState,
    required this.messages,
  });

  TcpState.encryptedConstuctor({
    required this.connectionState,
    required this.messages,
  });

  factory TcpState.initial() {
    return const TcpState(
        connectionState: SocketConnectionState.None,
        messages: <Iterable<int>>[]);
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
}
