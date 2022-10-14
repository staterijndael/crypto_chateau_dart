import 'dart:convert';

import 'package:flutter/foundation.dart';

Uint8List decorateRawDataByHandlerName(String handlerName, Uint8List data) {
  Uint8List decoratedRawData =
      Uint8List(handlerName.codeUnits.length + data.length);

  decoratedRawData.addAll(handlerName.codeUnits);
  decoratedRawData.add(utf8.encode('#')[0]);
  decoratedRawData.addAll(data);

  return decoratedRawData;
}
