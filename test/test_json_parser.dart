import 'dart:async';

import 'package:parser_combinator/extra/json_parser.dart' as json_parser;
import 'package:parser_combinator/parser_combinator.dart';
import 'package:parser_combinator/parsing.dart';
import 'package:parser_combinator/runtime.dart';
import 'package:parser_combinator/streaming.dart';
import 'package:test/test.dart';

void main(List<String> args) {
  _test();
}

Object? _parse(bool mode, String source) {
  if (mode) {
    return parseString(json_parser.parser.parse, source);
  } else {
    return parseString(json_parser.parser.parse, source);
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

  final result = json_parser.parser.parseAsync(state);
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

void _test() {
  test('JSON parser', () async {
    {
      const source = '0';
      const result = 0;
      await _testAll(source, result);
    }

    {
      const source = '-0';
      const result = -0;
      await _testAll(source, result);
    }

    {
      const source = '1';
      const result = 1;
      await _testAll(source, result);
    }

    {
      const source = '-1';
      const result = -1;
      await _testAll(source, result);
    }

    {
      const source = '1.1';
      const result = 1.1;
      await _testAll(source, result);
    }

    {
      const source = '1.1e1';
      const result = 1.1e1;
      await _testAll(source, result);
    }

    {
      const source = '1.1e+1';
      const result = 1.1e+1;
      await _testAll(source, result);
    }

    {
      const source = '1.1e-1';
      const result = 1.1e-1;
      await _testAll(source, result);
    }

    {
      const source = '[false, true]';
      const result = [false, true];
      await _testAll(source, result);
    }

    {
      const source = 'false';
      const result = false;
      await _testAll(source, result);
    }

    {
      const source = 'null';
      const result = null;
      await _testAll(source, result);
    }

    {
      const source = 'true';
      const result = true;
      await _testAll(source, result);
    }
  });
}

Future<void> _testAll(String source, Object? result) async {
  final r1 = _parse(false, source);
  final r2 = _parse(true, source);
  final r3 = await _parseAsync(source);
  for (final r in [r1, r2, r3]) {
    expect(r, result);
  }
}
