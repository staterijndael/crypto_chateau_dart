import 'dart:convert';

import 'package:flutter/foundation.dart';

Uint8List decorateRawDataByHandlerName(String handlerName, Uint8List data) {
  Uint8List decoratedRawData =
      Uint8List(handlerName.codeUnits.length + data.length);

  for (int i = 0; i < handlerName.codeUnits.length; i++) {
    decoratedRawData[i] = handlerName.codeUnits[i];
  }
  decoratedRawData[handlerName.codeUnits.length] = utf8.encode('#')[0];
  for (int i = handlerName.codeUnits.length + 1;
      i < handlerName.codeUnits.length + 1 + data.length;
      i++) {
    decoratedRawData[i] = data[i];
  }

  return decoratedRawData;
}
