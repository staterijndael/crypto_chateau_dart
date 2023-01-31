const int protocolVersion = 1; // 4bits: min 0 max 7
const codegenVersion = "1.0.0"; // TODO: get from git on build

int newProtocolByte() {
  return protocolVersion | 15; // first 4 bits reserved
}
