import 'dart:async';

import 'package:crypto_chateau_dart/transport/connection/bytes_reader.dart';
import 'package:crypto_chateau_dart/transport/connection/bytes_writer.dart';
import 'package:crypto_chateau_dart/transport/connection/connection.dart';

class ConnectionController implements Connection {
  final _readController = StreamController<BytesReader>(sync: true);
  final Stream<ConnectionState> connectionState;
  void Function(BytesWriter bytes)? onWrite;
  void Function()? onListen;
  FutureOr<void> Function()? onCancel;

  ConnectionController({
    required this.connectionState,
    this.onWrite,
    this.onListen,
    this.onCancel,
  }) {
    _readController.onListen = () => onListen?.call();
    _readController.onCancel = () async {
      await close();
      await onCancel?.call();
    };
  }

  Future<void> close() => _readController.close();

  @override
  Stream<BytesReader> get read => _readController.stream;

  @override
  void write(BytesWriter bytes) => onWrite?.call(bytes);

  void add(BytesReader bytes) => _readController.add(bytes);
}
