import 'package:crypto_chateau_dart/transport/connection/connection.dart';

import 'def.dart';

void main() async {
  // const kConnectParams = ConnectParams(
  //   host: '45.141.102.178',
  //   port: 8080,
  //   isEncryptionEnabled: true,
  // );

  const kConnectParams = ConnectParams(
    host: '127.0.0.1',
    port: 8084,
    isEncryptionEnabled: true,
  );

  final client = Client(
    connectParams: kConnectParams,
  );

  await Future.wait([
    for (var i = 0; i < 1000; i++)
      client.reverseString(ReverseStringReq(Str: '$i: ILYA SUKA EBANNAYA BLYATB!')).then((value) => print(value.Res.split('').reversed.join()))
  ]);
}
