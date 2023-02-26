import 'gen_definitions.dart';

void main() async {
  final kConnectParams = ConnectParams(
    host: '45.141.102.178',
    port: 8080,
    isEncryptionEnabled: true,
  );

  final client = Client(
    connectParams: kConnectParams,
  );

  // await Future.delayed(const Duration(milliseconds: 1000));
  final response = await client.reverseString(const ReverseStringRequestAlt(str: 'alice'));
  print(response.res);
}
