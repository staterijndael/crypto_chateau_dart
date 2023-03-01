import 'package:crypto_chateau_dart/transport/connection/connection.dart';

import 'def.dart';

void main() async {
  const kConnectParams = ConnectParams(
    host: '45.141.102.178',
    port: 8080,
    isEncryptionEnabled: true,
  );

  final _results = <String>[];

  // await Future.wait([
  //   for (var i = 0; i < 100; i++)
  //     Client(connectParams: kConnectParams)
  //         .reverseString(ReverseStringReq(Str: 'alice$i'))
  //         .then((value) => print(value.Res.split('').reversed.join()))
  // ]);

  final client = Client(
    connectParams: kConnectParams,
  );

  final resp = await client.reverseString(ReverseStringReq(Str: 'alice')).then((value) => print(value.Res.split('').reversed.join()));


  // await Future.wait([
  //   for (var i = 0; i < 10; i++)
  //     client.reverseString(ReverseStringReq(Str: 'alice$i')).then((value) => print(value.Res.split('').reversed.join()))
  // ]);
}
