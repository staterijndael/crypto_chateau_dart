import 'dart:collection';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/aes_256/aes_256.dart' as aes;
import 'package:crypto_chateau_dart/transport/bytes_writer.dart';

class BytesBuffer {
  final _properties = List<Property>.empty(growable: true);

  BytesBuffer();

  UnmodifiableListView<Property> get properties => UnmodifiableListView(_properties);

  void add(Property property) => _properties.add(property);

  Uint8List toBytes() {
    final writer = BytesWriter();

    for (var property in _properties) {
      property.apply(writer);
    }

    return writer.toBytes();
  }

  @override
  String toString() => toBytes().toString();
}

abstract class Property {
  void apply(BytesWriter writer);
}

class RequestId implements Property {
  final int id;

  const RequestId(this.id);

  @override
  void apply(BytesWriter writer) {}
}

class Data implements Property {
  final Uint8List data;

  const Data(this.data);

  @override
  void apply(BytesWriter writer) => writer.addFirst(data);
}

class Length implements Property {
  const Length();

  @override
  void apply(BytesWriter writer) {
    final length = writer.length;
    final bytes = Uint8List(2)
      ..[0] = length & 0xff
      ..[1] = (length & 0xff00) >> 8;
    writer.addFirst(bytes);
  }
}

class Multiplex implements Property {
  final int requestId;

  const Multiplex(this.requestId);

  @override
  void apply(BytesWriter writer) {
    final bytes = Uint8List(2)
      ..[0] = (requestId >> 0) & 0xFF
      ..[1] = (requestId >> 8) & 0xFF;
    writer.addFirst(bytes);
  }
}

class Encrypt implements Property {
  final Uint8List sharedKey;

  const Encrypt(this.sharedKey);

  @override
  void apply(BytesWriter writer) {
    final bytes = writer.takeBytes();
    final newBytes = aes.Encrypt(bytes, sharedKey);
    writer.addFirst(newBytes);
  }
}
