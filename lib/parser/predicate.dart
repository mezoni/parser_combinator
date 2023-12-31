bool isAlpha(int c) => c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A;

bool isAlphanumeric(int c) =>
    c >= 0x30 && c <= 0x39 || c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A;

bool isDigit(int c) => c >= 0x30 && c <= 0x39;

bool isHexDigit(int c) =>
    c >= 0x30 && c <= 0x39 || c >= 0x41 && c <= 0x46 || c >= 0x61 && c <= 0x66;

bool isWhitespace(int c) => c == 0x9 || c == 0xa || c == 0xd || c == 0x20;
