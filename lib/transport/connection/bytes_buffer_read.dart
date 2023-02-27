import 'dart:collection';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/aes_256/aes_256.dart' as aes;

class BytesBuffer {
  final Uint8List _rawBytes;
  final _properties = List<Property>.empty(growable: true);

  BytesBuffer(this._rawBytes);

  UnmodifiableListView<Property> get properties => UnmodifiableListView(_properties);

  int get length => _rawBytes.length;

  Uint8List get bytes => Uint8List.fromList(_rawBytes);

  T add<T extends Property>(PropertyApplier<T> applier) {
    final property = applier.apply(_rawBytes);
    _properties.add(property);

    return property;
  }

  @override
  String toString() => _rawBytes.toString();
}

abstract class Property {}

abstract class PropertyApplier<T extends Property> {
  T apply(Uint8List bytes);
}

class DataApplier implements PropertyApplier<Data> {
  final int? length;

  const DataApplier([this.length]);

  @override
  Data apply(Uint8List bytes) {
    if (length == null) {
      final data = Uint8List.fromList(bytes);
      bytes.clear();

      return Data(data);
    }

    final data = bytes.sublist(0, length!);
    bytes.removeRange(0, length!);

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
  Length apply(Uint8List bytes) {
    final length = bytes[0] | bytes[1] << 8;
    bytes.removeRange(0, 1);

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
  Multiplex apply(Uint8List bytes) {
    final requestId = (bytes[0] & 0xff) | ((bytes[1] & 0xff) << 8);
    bytes.removeRange(0, 1);

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
  Decrypt apply(Uint8List bytes) {
    final newBytes = aes.Decrypt(bytes, sharedKey);
    bytes.clear();
    bytes.addAll(newBytes);

    return const Decrypt();
  }
}

class Decrypt implements Property {
  const Decrypt();
}
