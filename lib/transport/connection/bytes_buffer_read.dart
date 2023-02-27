import 'dart:collection';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/aes_256/aes_256.dart' as aes;
import 'package:crypto_chateau_dart/transport/bytes_reader.dart';

class BytesBuffer {
  final BytesReader _reader;
  final _properties = List<Property>.empty(growable: true);

  BytesBuffer(Uint8List bytes) : _reader = BytesReader(bytes);

  UnmodifiableListView<Property> get properties => UnmodifiableListView(_properties);

  int get length => _reader.length;

  Uint8List get bytes => _reader.bytes;

  T add<T extends Property>(PropertyApplier<T> applier) {
    final property = applier.apply(_reader);
    _properties.add(property);

    return property;
  }

  @override
  String toString() => _reader.toString();
}

abstract class Property {}

abstract class PropertyApplier<T extends Property> {
  T apply(BytesReader reader);
}

class DataApplier implements PropertyApplier<Data> {
  final int? length;

  const DataApplier([this.length]);

  @override
  Data apply(BytesReader reader) {
    if (length == null) {
      final data = reader.bytes;
      reader.clear();

      return Data(data);
    }

    final data = reader.bytes.sublist(0, length!);
    reader.removeLeft(length!);

    return Data(data);
  }
}

class Data implements Property {
  final Uint8List data;

  const Data(this.data);
}

class LengthApplier implements PropertyApplier<Length> {
  const LengthApplier();

  @override
  Length apply(BytesReader reader) {
    final bytes = reader.bytes;
    final length = bytes[0] | bytes[1] << 8;
    reader.removeLeft(2);

    return Length(length);
  }
}

class Length implements Property {
  final int length;

  const Length(this.length);
}

class MultiplexApplier implements PropertyApplier<Multiplex> {
  const MultiplexApplier();

  @override
  Multiplex apply(BytesReader reader) {
    final bytes = reader.bytes;
    final requestId = (bytes[0] & 0xff) | ((bytes[1] & 0xff) << 8);
    reader.removeLeft(2);

    return Multiplex(requestId);
  }
}

class Multiplex implements Property {
  final int requestId;

  const Multiplex(this.requestId);
}

class DecryptApplier implements PropertyApplier<Decrypt> {
  final Uint8List sharedKey;

  const DecryptApplier(this.sharedKey);

  @override
  Decrypt apply(BytesReader reader) {
    final newBytes = aes.Decrypt(reader.bytes, sharedKey);
    reader.rewrite(newBytes);

    return const Decrypt();
  }
}

class Decrypt implements Property {
  const Decrypt();
}
