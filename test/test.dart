// import 'package:crypto_chateau_dart/gen_definitions.dart';
//
// void main() async {
//   final kConnectParams = ConnectParams(
//     host: '45.141.102.178',
//     port: 8080,
//     isEncryptionEnabled: true,
//   );
//
//   final client = Client(
//     connectParams: kConnectParams,
//   );
//
//   Future.wait([
//     for (var i = 0; i < 10; i++)
//       client.reverseString(ReverseStringRequestAlt(str: 'alice$i')).then((value) => print('$i: ${value.res}'))
//   ]);
// }
