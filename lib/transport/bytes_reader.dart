import 'dart:typed_data';

class BytesReader {
  Uint8List _source;
  int _leftOffset = 0;
  int _rightOffset = 0;

  BytesReader(this._source);

  int get length => _source.length - _leftOffset - _rightOffset;

  Uint8List get bytes => Uint8List.sublistView(_source, _leftOffset, _source.length - _rightOffset);

  void removeLeft(int count) => _leftOffset += count;

  void removeRight(int count) => _rightOffset -= count;

  void rewrite(Uint8List list) {
    _source = list;
    _rightOffset = 0;
    _leftOffset = 0;
  }

  void clear() {
    _source = Uint8List(0);
    _rightOffset = 0;
    _leftOffset = 0;
  }

  @override
  String toString() => _source.toString();
}
