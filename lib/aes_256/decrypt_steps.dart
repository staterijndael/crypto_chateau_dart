import 'dart:typed_data';

import 'multiply.dart';
import 'params.dart';

List<Uint16List> InvShiftRows(List<Uint16List> state) {
  for (var row = 1; row < Nb; row++) {
    Uint16List res = Uint16List(4);
    for (var col = 0; col < 4; col++) {
      res[(col + row) % 4] = state[row][col];
    }

    state[row] = res;
  }

  return state;
}

List<Uint16List> InvMixColumns(List<Uint16List> state) {
  for (var row = 0; row < Nb; row++) {
    var s0 = mulBy0e(state[0][row]) ^
        mulBy0b(state[1][row]) ^
        mulBy0d(state[2][row]) ^
        mulBy09(state[3][row]);
    var s1 = mulBy09(state[0][row]) ^
        mulBy0e(state[1][row]) ^
        mulBy0b(state[2][row]) ^
        mulBy0d(state[3][row]);
    var s2 = mulBy0d(state[0][row]) ^
        mulBy09(state[1][row]) ^
        mulBy0e(state[2][row]) ^
        mulBy0b(state[3][row]);
    var s3 = mulBy0b(state[0][row]) ^
        mulBy0d(state[1][row]) ^
        mulBy09(state[2][row]) ^
        mulBy0e(state[3][row]);

    state[0][row] = s0;
    state[1][row] = s1;
    state[2][row] = s2;
    state[3][row] = s3;
  }

  return state;
}

List<Uint16List> InvSubBytes(List<Uint16List> state) {
  for (var i = 0; i < state.length; i++) {
    for (var j = 0; j < state.length; j++) {
      var sboxElem = InvSbox[state[i][j]];
      state[i][j] = sboxElem;
    }
  }

  return state;
}
