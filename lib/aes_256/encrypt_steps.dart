import 'dart:typed_data';

import 'multiply.dart';
import 'params.dart';

List<Uint16List> subBytes(List<Uint16List> state) {
  for (var i = 0; i < state.length; i++) {
    for (var j = 0; j < state[i].length; j++) {
      int row = state[i][j] ~/ 0x10;
      var col = state[i][j] % 0x10;

      var sboxElem = Sbox[16 * row + col];
      state[i][j] = sboxElem;
    }
  }

  return state;
}

List<Uint16List> keyExpansion(Uint8List key) {
  if (key.length != 4 * Nk) {
    throw "incorrect len of secret key(should be 32(4 * nk))";
  }

  List<Uint16List> keySchedule = List.filled(4, Uint16List(0), growable: false);

  for (var r = 0; r < 4; r++) {
    keySchedule[r] = Uint16List(Nb * (Nr + 1));
    for (var c = 0; c < Nk; c++) {
      keySchedule[r][c] = key[r + 4 * c];
    }
  }

  for (var col = Nk; col < Nb * (Nr + 1); col++) {
    if (col % Nk == 0) {
      Uint16List tmpPrevCol = Uint16List(4);
      for (var row = 1; row < 4; row++) {
        tmpPrevCol[row - 1] = keySchedule[row][col - 1];
      }

      tmpPrevCol[tmpPrevCol.length - 1] = keySchedule[0][col - 1];

      for (var i = 0; i < tmpPrevCol.length; i++) {
        var sboxElem = Sbox[tmpPrevCol[i]];
        tmpPrevCol[i] = sboxElem;
      }

      for (var row = 0; row < 4; row++) {
        var s = keySchedule[row][col - 4] ^
            tmpPrevCol[row] ^
            Rcon[row][col ~/ Nk - 1];
        keySchedule[row][col] = s;
      }
    } else {
      for (var row = 0; row < 4; row++) {
        var s = keySchedule[row][col - 4] ^ keySchedule[row][col - 1];
        keySchedule[row][col] = s;
      }
    }
  }

  return keySchedule;
}

List<Uint16List> addRoundKey(
    List<Uint16List> state, List<Uint16List> keySchedule, int round) {
  for (var col = 0; col < Nb; col++) {
    for (var row = 0; row < Nb; row++) {
      var s = state[row][col] ^ keySchedule[row][Nb * round + col];

      state[row][col] = s;
    }
  }

  return state;
}

List<Uint16List> mixColumns(List<Uint16List> state) {
  for (var row = 0; row < Nb; row++) {
    var s0 = mulBy02(state[0][row]) ^
        mulBy03(state[1][row]) ^
        state[2][row] ^
        state[3][row];
    var s1 = state[0][row] ^
        mulBy02(state[1][row]) ^
        mulBy03(state[2][row]) ^
        state[3][row];
    var s2 = state[0][row] ^
        state[1][row] ^
        mulBy02(state[2][row]) ^
        mulBy03(state[3][row]);
    var s3 = mulBy03(state[0][row]) ^
        state[1][row] ^
        state[2][row] ^
        mulBy02(state[3][row]);

    state[0][row] = s0;
    state[1][row] = s1;
    state[2][row] = s2;
    state[3][row] = s3;
  }

  return state;
}

List<Uint16List> shiftRows(List<Uint16List> state) {
  for (var row = 1; row < Nb; row++) {
    Uint16List res = Uint16List(4);
    for (var col = 0; col < 4; col++) {
      var shift = (4 - 1 - col - row) % 4;
      if (shift < 0) {
        shift = 4 + shift;
      }
      res[shift] = state[row][4 - 1 - col];
    }

    state[row] = res;
  }

  return state;
}
