import 'dart:convert';
import 'dart:typed_data';

abstract class Message {
  Uint8List Marshal();
  void Unmarshal(Map<String, Uint8List> params);
}

class Error extends Message {
  final String handlerName;
  final String msg;

  Error({required this.handlerName, required this.msg});

  @override
  Unmarshal(Map<String, Uint8List> params) {
    // TODO: implement Unmarshal
    throw UnimplementedError();
  }

  @override
  Uint8List Marshal() {
    // TODO: implement Marshal
    throw UnimplementedError();
  }
}