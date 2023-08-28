abstract interface class ByteReader {
  int get length;

  int readByte(int offset);
}

abstract interface class StringReader {
  factory StringReader(String source) {
    return _StringReader(source);
  }

  int get count;

  int get length;

  String? get source;

  int readChar(int offset);

  bool startsWith(String string, [int index = 0]);

  String substring(int start, [int? end]);
}

class _StringReader implements StringReader {
  @override
  final int length;

  @override
  int count = 0;

  @override
  final String source;

  _StringReader(this.source) : length = source.length;

  @override
  @pragma('vm:prefer-inline')
  int readChar(int offset) {
    final result = source.runeAt(offset);
    count = result > 0xffff ? 2 : 1;
    return result;
  }

  @override
  @pragma('vm:prefer-inline')
  bool startsWith(String string, [int index = 0]) {
    if (source.startsWith(string, index)) {
      count = string.length;
      return true;
    }

    return false;
  }

  @override
  @pragma('vm:prefer-inline')
  String substring(int start, [int? end]) {
    final result = source.substring(start, end);
    count = result.length;
    return result;
  }

  @override
  String toString() {
    return source;
  }
}

extension on String {
  @pragma('vm:prefer-inline')
  int runeAt(int index) {
    final w1 = codeUnitAt(index++);
    if (w1 > 0xd7ff && w1 < 0xe000) {
      if (index < length) {
        final w2 = codeUnitAt(index);
        if ((w2 & 0xfc00) == 0xdc00) {
          return 0x10000 + ((w1 & 0x3ff) << 10) + (w2 & 0x3ff);
        }
      }

      throw FormatException('Invalid UTF-16 character', this, index - 1);
    }

    return w1;
  }
}

class Utf8Reader implements StringReader {
  final ByteReader reader;

  int _char = 0;

  int _lastIndex = -1;

  int _markerSize = 0;

  int _readDataSize = 0;

  Utf8Reader(this.reader, {bool detectBOM = true}) {
    if (detectBOM) {
      _detectBOM();
    }
  }

  @override
  int get count => _readDataSize;

  @override
  int get length => reader.length - _markerSize;

  @override
  String? get source => null;

  @override
  int readChar(int index) {
    if (index < 0) {
      throw ArgumentError.value(index, 'index', 'Must not be negative');
    }

    if (_lastIndex == index) {
      return _char;
    }

    final c = _read(index);
    _lastIndex = index;
    _char = c;
    return c;
  }

  @override
  bool startsWith(String string, [int index = 0]) {
    _lastIndex = -1;
    var readDataSize = 0;
    final iterator = string.runes.iterator;
    while (iterator.moveNext()) {
      final c1 = iterator.current;
      final c2 = _read(index);
      if (c1 != c2) {
        _readDataSize = 0;
        return false;
      }

      index += _readDataSize;
      readDataSize += _readDataSize;
    }

    _readDataSize = readDataSize;
    return true;
  }

  @override
  String substring(int start, [int? end]) {
    if (end != null && start > end) {
      throw RangeError.range(start, 0, end, 'start');
    }

    _lastIndex = -1;
    var index = start;
    var readDataSize = 0;
    if (end != null) {
      if (start > end) {
        throw RangeError.range(start, 0, end, 'start');
      }

      if (end - start == 0) {
        _readDataSize = 0;
        return '';
      }
    }

    end ??= length;
    final charCodes = <int>[];
    for (var i = 0; index < end; i++) {
      final c = _read(index);
      charCodes.add(c);
      index += _readDataSize;
      readDataSize += _readDataSize;
    }

    _lastIndex = start;
    _char = charCodes[0];
    _readDataSize = readDataSize;
    return String.fromCharCodes(charCodes);
  }

  void _detectBOM() {
    if (length >= 3) {
      if (_readByte(0) == 0xef) {
        if (_readByte(1) == 0xbb) {
          if (_readByte(2) == 0xbf) {
            _markerSize = 3;
          }
        }
      }
    }
  }

  Never _error(int offset, int char) {
    final hexValue = char.toRadixString(16);
    throw StateError(
        'Invalid character at offset $offset: $_char (0x$hexValue)');
  }

  int _read(int index) {
    final byte1 = _readByte(index + _markerSize);
    var c = 0;
    if (byte1 < 0x80) {
      _readDataSize = 1;
      return byte1;
    } else if ((byte1 & 0xe0) == 0xc0) {
      _readDataSize = 2;
      final byte2 = _readByte(index + _markerSize + 1);
      c = ((byte1 & 0x1f) << 6) | (byte2 & 0x3f);
    } else if ((byte1 & 0xf0) == 0xe0) {
      _readDataSize = 3;
      final byte2 = _readByte(index + _markerSize + 1);
      final byte3 = _readByte(index + _markerSize + 2);
      c = ((byte1 & 0x0f) << 12) | ((byte2 & 0x3f) << 6) | (byte3 & 0x3f);
    } else if ((byte1 & 0xf8) == 0xf0 && (byte1 <= 0xf4)) {
      _readDataSize = 4;
      final byte2 = _readByte(index + _markerSize + 1);
      final byte3 = _readByte(index + _markerSize + 2);
      final byte4 = _readByte(index + _markerSize + 3);
      c = ((byte1 & 0x07) << 18) |
          ((byte2 & 0x3f) << 12) |
          ((byte3 & 0x3f) << 6) |
          (byte4 & 0x3f);
    } else {
      _error(index, c);
    }

    if (c >= 0xd800 && c <= 0xdfff) {
      _error(index, c);
    }

    return c;
  }

  int _readByte(int index) {
    return reader.readByte(index);
  }
}
