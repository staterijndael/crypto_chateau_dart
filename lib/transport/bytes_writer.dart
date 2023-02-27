import 'dart:collection';
import 'dart:typed_data';

class BytesWriter {
  int _length = 0;
  final _chunks = Queue<Uint8List>();

  void addFirst(List<int> bytes) {
    final typedBytes = _bytesToTypedBytes(bytes);
    _chunks.addFirst(typedBytes);
    _length += typedBytes.length;
  }

  void addLast(List<int> bytes) {
    final typedBytes = _bytesToTypedBytes(bytes);
    _chunks.addLast(typedBytes);
    _length += typedBytes.length;
  }

  void addFirstByte(int byte) {
    _chunks.addFirst(_bytesToList(byte));
    _length++;
  }

  void addLastByte(int byte) {
    _chunks.addLast(_bytesToList(byte));
    _length++;
  }

  Uint8List takeBytes() {
    if (_length == 0) return Uint8List(0);

    if (_chunks.length == 1) {
      var buffer = _chunks.first;
      clear();

      return buffer;
    }

    var buffer = Uint8List(_length);
    int offset = 0;

    for (var chunk in _chunks) {
      buffer.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    clear();

    return buffer;
  }

  Uint8List toBytes() {
    if (_length == 0) return Uint8List(0);

    var buffer = Uint8List(_length);
    int offset = 0;

    for (var chunk in _chunks) {
      buffer.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    return buffer;
  }

  int get length => _length;

  bool get isEmpty => _length == 0;

  bool get isNotEmpty => _length != 0;

  void clear() {
    _length = 0;
    _chunks.clear();
  }

  Uint8List _bytesToTypedBytes(List<int> bytes) => bytes is Uint8List ? bytes : Uint8List.fromList(bytes);

  Uint8List _bytesToList(int byte) => Uint8List(1)..[0] = byte;
}
