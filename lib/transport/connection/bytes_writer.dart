import 'dart:collection';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/aes_256/aes_256.dart' as aes;
import 'package:crypto_chateau_dart/transport/bytes_writer.dart';

class BytesWriter {
  final _properties = List<Property>.empty(growable: true);

  BytesWriter();

  UnmodifiableListView<Property> get properties => UnmodifiableListView(_properties);

  void add(Property property) => _properties.add(property);

  Uint8List toBytes() {
    final builder = BytesBuilderQueue();

    for (var property in _properties) {
      property.apply(builder);
    }

    return builder.toBytes();
  }

  @override
  String toString() => toBytes().toString();
}

extension BytesWriterX on BytesWriter {
  void writeData(Uint8List data) => add(_Data(data));

  void writeLength() => add(const _Length());

  void writeMultiplex(int requestId) => add(_Multiplex(requestId));

  void encrypt(Uint8List sharedKey) => add(_Encrypt(sharedKey));
}

abstract class Property {
  void apply(BytesBuilderQueue builder);
}

class _Data implements Property {
  final Uint8List data;

  const _Data(this.data);

  @override
  void apply(BytesBuilderQueue builder) => builder.addFirst(data);
}

class _Length implements Property {
  const _Length();

  @override
  void apply(BytesBuilderQueue builder) {
    final length = builder.length;
    final bytes = Uint8List(2)
      ..[0] = length & 0xff
      ..[1] = (length & 0xff00) >> 8;
    builder.addFirst(bytes);
  }
}

class _Multiplex implements Property {
  final int requestId;

  const _Multiplex(this.requestId);

  @override
  void apply(BytesBuilderQueue builder) {
    final bytes = Uint8List(2)
      ..[0] = (requestId >> 0) & 0xFF
      ..[1] = (requestId >> 8) & 0xFF;
    builder.addFirst(bytes);
  }
}

class _Encrypt implements Property {
  final Uint8List sharedKey;

  const _Encrypt(this.sharedKey);

  @override
  void apply(BytesBuilderQueue builder) {
    final bytes = builder.takeBytes();
    final newBytes = aes.Encrypt(bytes, sharedKey);
    builder.addFirst(newBytes);
  }
}
