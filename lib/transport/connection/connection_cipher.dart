part of connection;

class ConnectionCipher implements Connection {
  final Connection _connection;
  final Encryption _encryption;

  const ConnectionCipher(this._connection, this._encryption);

  @override
  Stream<r.BytesBuffer> get read => _connection.read.map(_decrypt);

  @override
  void write(w.BytesBuffer bytes) => _connection.write(_encrypt(bytes));

  r.BytesBuffer _decrypt(r.BytesBuffer bytes) => _encryption.key.when(
        isNull: () => bytes,
        isNotNull: (sharedKey) => bytes..add(r.DecryptApplier(sharedKey)),
      );

  w.BytesBuffer _encrypt(w.BytesBuffer bytes) => _encryption.key.when(
    isNull: () => bytes,
    isNotNull: (sharedKey) => bytes..add(w.Encrypt(sharedKey)),
  );
}
