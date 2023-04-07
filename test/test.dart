import 'dart:typed_data';

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

  // await Future.wait([
  //   for (var i = 0; i < 2; i++)
  //     client.reverseString(ReverseStringReq(Str: '$i: DANIA CREATE FACTORIES!!!')).then((value) => print(value.Res.split('').reversed.join()))
  // ]);

  // await Future.delayed(const Duration(seconds: 10));

  // await Future.wait([
  //   for (var i = 0; i < 2; i++)
  //     client.reverseString(ReverseStringReq(Str: '$i: DANIA CREATE FACTORIES!!!')).then((value) => print(value.Res.split('').reversed.join()))
  // ]);

  // await Future.delayed(const Duration(seconds: 10));

  // await Future.wait([
  //   for (var i = 0; i < 2; i++)
  //     client.reverseString(ReverseStringReq(Str: '$i: DANIA CREATE FACTORIES!!!')).then((value) => print(value.Res.split('').reversed.join()))
  // ]);

  final repsonse = await client.findUsersByPartNickname(
    FindUsersByPartNicknameRequest(
      SessionToken: sessionToken,
      PartNickname: '',
    ),
  );

  print(repsonse);
}

final sessionToken = Uint8List.fromList([49, 81, 84, 41, 194, 172, 75, 60, 172, 204, 249, 228, 154, 76, 36, 157]);
