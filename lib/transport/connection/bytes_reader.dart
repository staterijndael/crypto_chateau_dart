import 'dart:typed_data';

import 'package:crypto_chateau_dart/aes_256/aes_256.dart' as aes;

class BytesReader {
  Uint8List _source;
  int _offset = 0;

  BytesReader(this._source);

  int get length => _source.length - _offset;

  bool get isEmpty => length == 0;

  bool get isNotEmpty => length > 0;

  Uint8List get bytes => Uint8List.sublistView(_source, _offset);

  int operator [](int index) => _source[index + _offset];

  Uint8List read([int? end]) {
    final newOffset = _offset + (end ?? length);
    final bytes = Uint8List.sublistView(_source, _offset, newOffset);
    _offset = newOffset;

    return bytes;
  }

  void readIdle([int? end]) {
    final newOffset = _offset + (end ?? length);
    RangeError.checkValidRange(_offset, _offset, newOffset);
    _offset = newOffset;
  }

  @override
  String toString() => bytes.toString();
}

extension BytesReaderX on BytesReader {
  int readLength() {
    final bytes = read(2);

    return bytes[0] | bytes[1] << 8;
  }

  int readMultiplex() {
    final bytes = read(2);

    return (bytes[0] & 0xff) | ((bytes[1] & 0xff) << 8);
  }

  BytesReader decrypt(Uint8List sharedKey) => BytesReader(aes.Decrypt(bytes, sharedKey));
}
