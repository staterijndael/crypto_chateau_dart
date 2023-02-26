part of connection;

class ConnectionCipher implements Connection {
  final Connection _connection;
  final Encryption _encryption;

  const ConnectionCipher(this._connection, this._encryption);

  @override
  Stream<Uint8List> get read => _connection.read.map(_decrypt);

  @override
  void write(Uint8List bytes) => _connection.write(_encrypt(bytes));

  Uint8List _decrypt(Uint8List bytes) => _encryption.key.when(
        isNull: () => bytes,
        isNotNull: (sharedKey) => Decrypt(bytes, sharedKey),
      );

  Uint8List _encrypt(Uint8List bytes) {
    print('Before encrypt: $bytes');

    return _encryption.key.when(
      isNull: () => bytes,
      isNotNull: (sharedKey) => Encrypt(bytes, sharedKey),
    );
  }
}
