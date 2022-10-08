import 'dart:math';
import 'dart:typed_data';

final Random _random = Random.secure();

void arraycopy(
    List<int> src, int srcPos, List<int> dest, int destPos, int length) {
  dest.setRange(destPos, length + destPos, src, srcPos);
}

Uint8List generateRandomBytes([int length = 32]) {
  final values = List<int>.generate(length, (i) => _random.nextInt(256));
  return Uint8List.fromList(values);
}