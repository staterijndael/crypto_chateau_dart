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

  var resp = await client.reverseString(ReverseStringReq(Str: 'alice1'));
  print(resp.Res);
}
