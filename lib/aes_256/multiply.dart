int mulBy02(int num) {
  int res = 0;

  if (num < 0x80) {
    res = num << 1;
  } else {
    res = (num << 1) ^ 0x1b;
  }

  return res % 0x100;
}

int mulBy03(int num) {
  return mulBy02(num) ^ num;
}

int mulBy09(int num) {
  return mulBy02(mulBy02(mulBy02(num))) ^ num;
}

int mulBy0b(int num) {
  return mulBy02(mulBy02(mulBy02(num))) ^ mulBy02(num) ^ num;
}

int mulBy0d(int num) {
  return mulBy02(mulBy02(mulBy02(num))) ^ mulBy02(mulBy02(num)) ^ num;
}

int mulBy0e(int num) {
  return mulBy02(mulBy02(mulBy02(num))) ^ mulBy02(mulBy02(num)) ^ mulBy02(num);
}
