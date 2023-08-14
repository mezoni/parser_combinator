import 'dart:io';
import 'dart:typed_data';

import 'string_reader.dart';

class FileReader {
  final int bufferSize;

  final RandomAccessFile fp;

  final Uint8List _buffer;

  int _end = -1;

  final int _length;

  int _start = -1;

  FileReader(
    this.fp, {
    required this.bufferSize,
    bool isFixedLength = true,
  })  : _buffer = Uint8List(bufferSize > 0
            ? bufferSize
            : throw ArgumentError.value(
                bufferSize, 'bufferSize', 'Must be greater than 0')),
        _length = isFixedLength ? fp.lengthSync() : -1;

  @pragma('vm:prefer-inline')
  int get length {
    if (_length >= 0) {
      return _length;
    }

    return fp.lengthSync();
  }

  @pragma('vm:prefer-inline')
  int readByte(int offset) {
    if (offset < 0) {
      RangeError.checkNotNegative(offset, 'offset');
    }

    if (offset < _start || offset > _end) {
      _readIntoBuffer(offset);
    }

    if (offset > _end) {
      throw RangeError.range(offset, 0, _end);
    }

    return _buffer[offset - _start];
  }

  void _readIntoBuffer(int offset) {
    fp.setPositionSync(offset);
    final result = fp.readIntoSync(_buffer, 0);
    _start = offset;
    _end = offset + result - 1;
  }
}

class Utf8FileReader implements StringReader {
  final FileReader reader;

  int _char = 0;

  int _lastIndex = -1;

  int _markerSize = 0;

  int _readDataSize = 0;

  Utf8FileReader(this.reader, {bool detectBOM = true}) {
    if (detectBOM) {
      _detectBOM();
    }
  }

  @override
  int get length => reader.length - _markerSize;

  @override
  int get count => _readDataSize;

  @override
  String? get source => throw UnimplementedError();

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
