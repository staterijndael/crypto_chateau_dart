part of connection;

class ConnectionPipe extends ConnectionBase {
  late final Pipe _pipe;

  ConnectionPipe(super._connection) {
    _pipe = Pipe(
      onRead: _controller.add,
      onWrite: super.write,
    );
  }

  @override
  void _read(r.BytesBuffer buffer) => _pipe.read(buffer);

  @override
  void write(w.BytesBuffer buffer) => _pipe.write(buffer);
}

class Pipe {
  void Function(r.BytesBuffer buffer) onRead;
  void Function(w.BytesBuffer buffer) onWrite;
  r.BytesBuffer? _reserved;

  Pipe({
    required this.onRead,
    required this.onWrite,
  });

  void read(r.BytesBuffer buffer) {
    final r.BytesBuffer current;
    final r.Length length;

    if (_reserved != null) {
      current = _reserved!..merge(buffer);
      length = current.properties.first as r.Length;
    } else {
      current = buffer;
      length = current.add(const r.LengthApplier());
    }

    if (buffer.length == length.length) {
      onRead?.call(buffer);
      _reserved = null;
    }
  }

  void write(w.BytesBuffer buffer) {
    buffer.add(const w.Length());
    onWrite?.call(buffer);
  }
}
