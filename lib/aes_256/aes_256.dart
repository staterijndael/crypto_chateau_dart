import 'dart:typed_data';

import 'decrypt_steps.dart';
import 'encrypt_steps.dart';
import 'params.dart';

Uint8List Encrypt(Uint8List inputBytes, Uint8List key) {
  if (inputBytes.isEmpty) {
    throw "incorrect input bytes length";
  }
  if (key.length != 4 * Nk) {
    throw "incorrect len of secret key(should be 32(4 * nk))";
  }

  var startIndex = inputBytes.length;
  var endIndex = inputBytes.length - 1;

  for (; (endIndex + 1) % (Nb * 4) != 0;) {
    endIndex++;
  }

  Uint8List correctedInputBytes = Uint8List(endIndex + 1);
  for (var i = 0; i < inputBytes.length; i++) {
    correctedInputBytes[i] = inputBytes[i];
  }

  for (var i = startIndex; i <= endIndex; i++) {
    correctedInputBytes[i] = ' ' as int;
  }

  Uint8List result = Uint8List(correctedInputBytes.length);

  for (var batch = 1; batch <= inputBytes.length / (Nb * 4); batch++) {
    var offset = (batch - 1) * Nb * 4;
    var limit = offset + Nb * 4;

    var state = correctedInputBytes.sublist(offset, limit);
    var encryptedData = encrypt(state, key);

    for (var i = 0; i < encryptedData.length; i++) {
      result[offset + i] = encryptedData[i];
    }
  }

  return result;
}

Uint8List Decrypt(Uint8List cipher, Uint8List key) {
  if (cipher.isEmpty || cipher.length % Nb * 4 != 0) {
    throw "incorrect input bytes length";
  }
  if (key.length != 4 * Nk) {
    throw "incorrect len of secret key(should be 32(4 * nk))";
  }

  Uint8List result = Uint8List(cipher.length);

  for (var batch = 1; batch <= cipher.length / (Nb * 4); batch++) {
    var offset = (batch - 1) * Nb * 4;
    var limit = offset + Nb * 4;

    var state = cipher.sublist(offset, limit);

    var decryptedData = decrypt(state, key);

    for (var i = 0; i < decryptedData.length; i++) {
      result[offset + i] = decryptedData[i];
    }
  }

  var finalIndex = result.length - 1;
  for (var i = result.length - 1; i >= 0; i--) {
    if (result[i] != ' ' as int) {
      finalIndex = i + 1;
      break;
    }
  }

  result = result.sublist(0, finalIndex);

  return result;
}

Uint8List encrypt(Uint8List inputBytes, Uint8List key) {
  if (inputBytes.length != 4 * Nb) {
    throw "incorrect input bytes length";
  }

  List<Uint16List> state = List.filled(4, Uint16List(Nb), growable: false);

  for (var r = 0; r < 4; r++) {
    for (var c = 0; c < Nb; c++) {
      state[r][c] = inputBytes[r + 4 * c];
    }
  }

  var keySchedule = keyExpansion(key);

  state = addRoundKey(state, keySchedule, 0);

  for (var rnd = 1; rnd < Nr; rnd++) {
    state = subBytes(state);
    state = shiftRows(state);
    state = mixColumns(state);
    state = addRoundKey(state, keySchedule, rnd);
  }

  state = subBytes(state);
  state = shiftRows(state);
  state = addRoundKey(state, keySchedule, Nr);

  Uint8List output = Uint8List(inputBytes.length);

  for (var row = 0; row < state.length; row++) {
    for (var col = 0; col < state[row].length; col++) {
      output[row + 4 * col] = state[row][col];
    }
  }

  return output;
}

Uint8List decrypt(Uint8List cipher, Uint8List key) {
  List<Uint16List> state = List.filled(4, Uint16List(4), growable: false);

  for (var r = 0; r < 4; r++) {
    for (var c = 0; c < Nb; c++) {
      state[r][c] = cipher[r + 4 * c];
    }
  }

  var keySchedule = keyExpansion(key);

  state = addRoundKey(state, keySchedule, Nr);

  for (var rnd = Nr - 1; rnd > 0; rnd--) {
    state = InvShiftRows(state);
    state = InvSubBytes(state);
    state = addRoundKey(state, keySchedule, rnd);
    state = InvMixColumns(state);
  }

  state = InvShiftRows(state);
  state = InvSubBytes(state);
  state = addRoundKey(state, keySchedule, 0);

  Uint8List output = Uint8List(cipher.length);

  for (var row = 0; row < state.length; row++) {
    for (var col = 0; col < state[row].length; col++) {
      output[row + 4 * col] = state[row][col];
    }
  }

  return output;
}
