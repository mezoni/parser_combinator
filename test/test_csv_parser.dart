import 'dart:async';

import 'package:parser_combinator/extra/csv_parser.dart' as csv;
import 'package:parser_combinator/parsing.dart';
import 'package:parser_combinator/runtime.dart';
import 'package:parser_combinator/streaming.dart';
import 'package:test/test.dart';

import '../tool/csv_parser_generated.dart' as csv_generated;

void main(List<String> args) {
  _test();
}

List<List<String>> _parse(bool mode, String source) {
  if (mode) {
    return parseString(csv.parser.parse, source);
  } else {
    return parseString(csv_generated.parser, source);
  }
}

Future<Object?> _parseAsync(String source) async {
  final completer = Completer<Object?>();
  final input = ChunkedData<StringReader>();
  final state = State(input);
  csv.parser.parseAsync(state, completer.complete);
  for (final element in source.runes) {
    input.add(StringReader(String.fromCharCode(element)));
  }

  input.close();
  return completer.future;
}

void _test() {
  for (final mode in [false, true]) {
    test('CSV parser', () async {
      {
        const s = '''
123''';
        final r1 = _parse(mode, s);
        expect(r1, [
          ['123']
        ]);
      }

      {
        const s = '''
123
''';
        final r1 = _parse(mode, s);
        expect(r1, [
          ['123']
        ]);
      }

      {
        const s = '''
123
456
''';
        final r1 = _parse(mode, s);

        expect(r1, [
          ['123'],
          ['456']
        ]);
      }

      {
        const s = '''
123,"abc😄"
456,def😄
''';
        final r1 = _parse(mode, s);
        expect(r1, [
          ['123', 'abc😄'],
          ['456', 'def😄']
        ]);
      }

      {
        const s = '''
123,"""abc😄"""
456,def😄
''';
        final r = _parse(mode, s);
        expect(r, [
          ['123', '"abc😄"'],
          ['456', 'def😄']
        ]);
      }

      {
        const s = '''
123,"ab""c😄"""
456,def😄
''';
        final r = _parse(mode, s);
        expect(r, [
          ['123', 'ab"c😄"'],
          ['456', 'def😄']
        ]);
      }

      {
        const s = '''
123,abc😄,1
456,def😄,
''';
        final r = _parse(mode, s);
        expect(r, [
          ['123', 'abc😄', '1'],
          ['456', 'def😄', '']
        ]);
      }

      {
        const s = '''
123,"multi
line",1
456,def😄,
''';
        final r = _parse(mode, s);
        expect(r, [
          ['123', 'multi\nline', '1'],
          ['456', 'def😄', '']
        ]);
      }

      {
        const s = '''
123,abc😄
456,"multi
line"

# Comment

789
''';
        final r = _parse(mode, s);
        expect(r, [
          ['123', 'abc😄'],
          ['456', 'multi\nline'],
          [''],
          ['# Comment'],
          [''],
          ['789'],
        ]);
      }
    });
  }
}
