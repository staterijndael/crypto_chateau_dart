import 'package:crypto_chateau_dart/transport/connection/connection.dart';

import 'def.dart';

void main() async {
  const kConnectParams = ConnectParams(
    host: '45.141.102.178',
    port: 8080,
    isEncryptionEnabled: true,
  );

  final client = Client(
    connectParams: kConnectParams,
  );

  await Future.wait([
    for (var i = 0; i < 256; i++)
      client.reverseString(ReverseStringReq(Str: '$i: DANIA CREATE FACTORIES!!!')).then((value) => print(value.Res.split('').reversed.join()))
  ]);

  await Future.wait([
    for (var i = 0; i < 256; i++)
      client.reverseString(ReverseStringReq(Str: '$i: DANIA CREATE FACTORIES!!!')).then((value) => print(value.Res.split('').reversed.join()))
  ]);

  await Future.wait([
    for (var i = 0; i < 256; i++)
      client.reverseString(ReverseStringReq(Str: '$i: DANIA CREATE FACTORIES!!!')).then((value) => print(value.Res.split('').reversed.join()))
  ]);
}
