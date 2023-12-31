import 'dart:async';

import 'package:parser_combinator/extra/csv_parser.dart' as csv;
import 'package:parser_combinator/parser_combinator.dart';
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
  final input = StringReaderChunkedData();
  final state = State(input);
  void handle(AsyncResult<Object?> result, void Function() f) {
    if (result.ok != null) {
      f();
    } else {
      result.handler = f;
    }
  }

  final result = csv.parser.parseAsync(state);
  handle(result, () {
    if (result.value == null) {
      completer.complete(null);
    } else {
      completer.complete(result.value!.value);
    }
  });
  for (final chunk in source.runes) {
    input.add(StringReader(String.fromCharCode(chunk)));
  }

  input.close();
  return completer.future;
}

Future<void> _testAll(String source, Object? result) async {
  final r1 = _parse(false, source);
  final r2 = _parse(true, source);
  final r3 = await _parseAsync(source);
  for (final r in [r1, r2, r3]) {
    expect(r, result);
  }
}

void _test() {
  test('CSV parser', () async {
    {
      const source = '''
1''';
      final result = [
        ['1']
      ];
      await _testAll(source, result);
    }

    {
      const source = '''
123''';
      final result = [
        ['123']
      ];
      await _testAll(source, result);
    }

    {
      const source = '''
123
''';
      final result = [
        ['123']
      ];
      await _testAll(source, result);
    }

    {
      const source = '''
123
456
''';
      final result = [
        ['123'],
        ['456']
      ];
      await _testAll(source, result);
    }

    {
      const source = '''
123,"abc😄"
456,def😄
''';
      final result = [
        ['123', 'abc😄'],
        ['456', 'def😄']
      ];
      await _testAll(source, result);
    }

    {
      const source = '''
123,"""abc😄"""
456,def😄
''';
      final result = [
        ['123', '"abc😄"'],
        ['456', 'def😄']
      ];
      await _testAll(source, result);
    }

    {
      const source = '''
123,"ab""c😄"""
456,def😄
''';
      final result = [
        ['123', 'ab"c😄"'],
        ['456', 'def😄']
      ];
      await _testAll(source, result);
    }

    {
      const source = '''
123,abc😄,1
456,def😄,
''';
      final result = [
        ['123', 'abc😄', '1'],
        ['456', 'def😄', '']
      ];
      await _testAll(source, result);
    }

    {
      const source = '''
123,"multi
line",1
456,def😄,
''';
      final result = [
        ['123', 'multi\nline', '1'],
        ['456', 'def😄', '']
      ];
      await _testAll(source, result);
    }

    {
      const source = '''
123,abc😄
456,"multi
line"

# Comment

789
''';
      final result = [
        ['123', 'abc😄'],
        ['456', 'multi\nline'],
        [''],
        ['# Comment'],
        [''],
        ['789'],
      ];
      await _testAll(source, result);
    }
  });
}
