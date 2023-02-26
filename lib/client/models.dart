import 'dart:typed_data';

import 'package:crypto_chateau_dart/client/binary_iterator.dart';

abstract class Message {
  Uint8List Marshal();
  void Unmarshal(BinaryIterator b);
}

class Error extends Message {
  final String handlerName;
  final String msg;

  Error({required this.handlerName, required this.msg});

  @override
  Unmarshal(BinaryIterator iterator) {
    // TODO: implement Unmarshal
    throw UnimplementedError();
  }

  @override
  Uint8List Marshal() {
    // TODO: implement Marshal
    throw UnimplementedError();
  }
}
