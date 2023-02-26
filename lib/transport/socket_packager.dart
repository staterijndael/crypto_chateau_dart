import 'dart:async';
import 'dart:typed_data';

class SocketPackager extends StreamTransformerBase<Uint8List, Uint8List> {
  const SocketPackager();

  @override
  Stream<Uint8List> bind(Stream<Uint8List> stream) {
    var reservedData = Uint8List(0);
    final controller = StreamController<Uint8List>(sync: true);
    final subscription = stream.listen(
          (event) {
        Uint8List buffer;

        if (reservedData.isEmpty) {
          buffer = reservedData = event;
        } else {
          buffer = reservedData..addAll(event);
        }

        final packetLength = buffer[0] | buffer[1] << 8;
        buffer = buffer.sublist(2);

        if (buffer.length == packetLength) {
          controller.add(buffer);
          reservedData = Uint8List(0);
        }

        if (buffer.length > packetLength) {
          controller.add(buffer.sublist(0, packetLength));
          reservedData = buffer.sublist(packetLength);
        }
      },
      onError: controller.addError,
      onDone: controller.close,
    );
    controller
      ..onResume = subscription.resume
      ..onPause = subscription.pause
      ..onCancel = subscription.cancel;

    return controller.stream;
  }
}

extension SocketDataReaderX on Stream<Uint8List> {
  Stream<Uint8List> pack() => transform(const SocketPackager());
}
