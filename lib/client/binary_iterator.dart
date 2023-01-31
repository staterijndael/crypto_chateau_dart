class BinaryIterator {
  List<int> bytes;
  int index;

  BinaryIterator(this.bytes, {this.index = 0});

  int nextSize() {
    if (index + 4 > bytes.length) {
      throw Exception("not enough bytes");
    }
    var result = 0;
    for (var i = 0; i < 4; i++) {
      result = (result << 8) + bytes[index + i];
    }
    index += 4;

    return result;
  }

  BinaryIterator slice(int n) {
    if (index + n > bytes.length) {
      throw Exception("not enough bytes");
    }
    var result = BinaryIterator(bytes.sublist(index, index + n));
    index += n;

    return result;
  }

  bool hasNext() {
    return index < bytes.length;
  }
}
