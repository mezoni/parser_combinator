import 'dart:convert';
import 'dart:io';

import 'package:parser_combinator/extra/json_parser.dart' as json_parser;
import 'package:parser_combinator/file_reader.dart';
import 'package:parser_combinator/parsing.dart';
import 'package:parser_combinator/string_reader.dart';
import 'package:test/test.dart';

void main() {
  _testFileReader();
  _testParsingUsingUtf8Reader();
  _testUtf8Reader();
}

void _testFileReader() {
  test('FileReader', () {
    const bufferSize = 8;
    for (var size = 1; size < bufferSize * 3; size++) {
      final file = File('test/temp.bin');
      if (file.existsSync()) {
        file.deleteSync();
      }

      file.writeAsBytesSync(List.generate(size, (i) => i));
      final reader = FileReader(file.openSync(), bufferSize: bufferSize);
      for (var i = 0; i < size; i++) {
        final byte = reader.readByte(i);
        expect(byte, i);
      }

      reader.fp.closeSync();
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  });
}

void _testParsingUsingUtf8Reader() {
  test('Parsing using Utf8Reader', () {
    const source = '{"rocket": "🚀 flies to the stars"}';
    final charCodes = source.codeUnits;
    var bytes = Utf8Encoder().convert(String.fromCharCodes(charCodes)).toList();
    final file = File('test/temp.json');
    if (file.existsSync()) {
      file.deleteSync();
    }

    bytes = [0xef, 0xbb, 0xbf, ...bytes];
    file.writeAsBytesSync(bytes);

    // Begin of parsing.
    final fileReader = FileReader(file.openSync(), bufferSize: 1024);
    final utf8Reader = Utf8Reader(fileReader);
    final result = parseInput(json_parser.parser.parse, utf8Reader);
    // End of parsing

    expect(result, {'rocket': '🚀 flies to the stars'});
    fileReader.fp.closeSync();
    if (file.existsSync()) {
      file.deleteSync();
    }
  });
}

void _testUtf8Reader() {
  test('Utf8Reader', () {
    for (var step = 0; step < 2; step++) {
      final charCodes = <int>[];
      for (var i = 0; i < 0xd800; i++) {
        charCodes.add(i);
      }

      for (var i = 0xe000; i < 0x10ffff; i++) {
        charCodes.add(i);
      }

      var bytes =
          Utf8Encoder().convert(String.fromCharCodes(charCodes)).toList();
      final file = File('test/temp.text');
      if (file.existsSync()) {
        file.deleteSync();
      }

      if (step > 0) {
        bytes = [0xef, 0xbb, 0xbf, ...bytes];
      }

      file.writeAsBytesSync(bytes);
      final fileReader = FileReader(file.openSync(), bufferSize: 1024);
      final utf8Reader = Utf8Reader(fileReader);
      final runes = String.fromCharCodes(charCodes).runes.toList();
      for (var i = 0, offset = 0; offset < utf8Reader.length; i++) {
        final c = utf8Reader.readChar(offset);
        offset += utf8Reader.count;
        final rune = runes[i];
        expect(c, rune);
      }

      fileReader.fp.closeSync();
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  });
}
