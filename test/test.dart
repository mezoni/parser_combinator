import 'dart:async';

import 'package:parser_combinator/parser/all_matches.dart';
import 'package:parser_combinator/parser/alpha.dart';
import 'package:parser_combinator/parser/alpha1.dart';
import 'package:parser_combinator/parser/and.dart';
import 'package:parser_combinator/parser/buffered.dart';
import 'package:parser_combinator/parser/char.dart';
import 'package:parser_combinator/parser/choice.dart';
import 'package:parser_combinator/parser/digit.dart';
import 'package:parser_combinator/parser/digit1.dart';
import 'package:parser_combinator/parser/has_match.dart';
import 'package:parser_combinator/parser/integer.dart';
import 'package:parser_combinator/parser/many.dart';
import 'package:parser_combinator/parser/many1.dart';
import 'package:parser_combinator/parser/many_till.dart';
import 'package:parser_combinator/parser/match.dart';
import 'package:parser_combinator/parser/predicate.dart';
import 'package:parser_combinator/parser/replace_all.dart';
import 'package:parser_combinator/parser/satisfy.dart';
import 'package:parser_combinator/parser/separated_list.dart';
import 'package:parser_combinator/parser/separated_list1.dart';
import 'package:parser_combinator/parser/separated_list_m_n.dart';
import 'package:parser_combinator/parser/separated_pair.dart';
import 'package:parser_combinator/parser/skip_while.dart';
import 'package:parser_combinator/parser/skip_while1.dart';
import 'package:parser_combinator/parser/tag.dart';
import 'package:parser_combinator/parser/tags.dart';
import 'package:parser_combinator/parser/tuple.dart';
import 'package:parser_combinator/parser_combinator.dart';
import 'package:parser_combinator/parsing.dart';
import 'package:parser_combinator/runtime.dart';
import 'package:parser_combinator/streaming.dart';
import 'package:parser_combinator/string_reader.dart';
import 'package:test/test.dart' hide Tags;

void main() async {
  _testAllMatches();
  _testAlpha();
  _testAlpha1();
  _testAnd(); // OK
  _testBuffered(); // OK
  _testChar(); //OK
  _testDigit();
  _testDigit1();
  _testHasMatch();
  _testInteger();
  _testMany(); // OK
  _testMany1(); // OK
  _testManyTill();
  _testMatch1();
  _testReplaceAll();
  _testSatisfy(); // OK
  _testSeparatedList();
  _testSeparatedList1();
  _testSeparatedListMN();
  _testSeparatedPair();
  _testSkipWhile();
  _testSkipWhile1();
  _testTag(); //OK
  _testTags();
}

const _bufferSize = 4;

String _errorExpectedCharacter(int char) =>
    ErrorExpectedCharacter(char).getErrorMessage(null, null).toString();

String _errorExpectedTags(List<String> tags) =>
    ErrorExpectedTags(tags).getErrorMessage(null, null).toString();

Set<String> _errorsToSet<I, O>(ParseResult<I, O> parseResult) {
  final errors = parseResult.errors;
  final failPos = parseResult.failPos;
  final input = parseResult.input;
  final result = <String>{};
  for (final element in errors) {
    final message = element.getErrorMessage(input, failPos);
    result.add(message.toString());
  }

  return result;
}

String _errorUnexpectedCharacter(StringReader input, int pos) =>
    ErrorUnexpectedCharacter().getErrorMessage(input, pos).toString();

Future<ParseResult<ChunkedData<StringReader>, Result<O>?>> _parseStream<O>(
  Parser<StringReader, O> p,
  int bufferSize,
  String source,
) {
  final input = ChunkedData<StringReader>();
  final completer =
      Completer<ParseResult<ChunkedData<StringReader>, Result<O>?>>();
  final state = State(input);
  p.parseStream(state, (result) {
    final r = createParseResult<ChunkedData<StringReader>, O, Result<O>?>(
      state,
      result,
      (e) => e != null,
    );
    completer.complete(r);
  });
  final stream = Stream.fromIterable(source.runes);
  stream.listen((event) {
    final string = String.fromCharCode(event);
    final chunk = StringReader(string);
    input.add(chunk);
  }, onDone: input.close);

  return completer.future;
}

void _testAllMatches() {
  test('AllMatches', () {
    {
      final p = AllMatches(Choice2(SkipWhile1(isAlpha), SkipWhile1(isDigit)));
      const source = '123abc456';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, [
        (start: 0, end: 3, value: '123'),
        (start: 3, end: 6, value: 'abc'),
        (start: 6, end: 9, value: '456'),
      ]);
      expect(r2.result, true);
      expect(r1.pos, 9);
      expect(r2.pos, 9);
    }

    {
      final p = AllMatches(Choice2(SkipWhile1(isAlpha), SkipWhile1(isDigit)));
      const source = '123!!!456';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, [
        (start: 0, end: 3, value: '123'),
        (start: 6, end: 9, value: '456'),
      ]);
      expect(r2.result, true);
      expect(r1.pos, 9);
      expect(r2.pos, 9);
    }

    {
      final p = AllMatches(Choice2(SkipWhile1(isAlpha), SkipWhile1(isDigit)));
      const source = '!!!abc!!!';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, [
        (start: 3, end: 6, value: 'abc'),
      ]);
      expect(r2.result, true);
      expect(r1.pos, 9);
      expect(r2.pos, 9);
    }

    {
      final p = AllMatches(Choice2(SkipWhile1(isAlpha), SkipWhile1(isDigit)));
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, <({int end, int offset, String value})>[]);
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }

    {
      final p = AllMatches(Choice2(SkipWhile1(isAlpha), SkipWhile1(isDigit)));
      const source = '!!!';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, <({int end, int offset, String value})>[]);
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }
  });
}

void _testAlpha() {
  test('Alpha', () {
    {
      final p = Alpha();
      const source = 'a';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, 'a');
      expect(r2.result, true);
      expect(r1.pos, 1);
      expect(r2.pos, 1);
    }

    {
      final p = Alpha();
      const source = 'abc';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, 'abc');
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = Alpha();
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '');
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }

    {
      final p = Alpha();
      const source = '1';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '');
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }
  });
}

void _testAlpha1() {
  test('Alpha1', () {
    {
      final p = Alpha1();
      const source = 'a';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, 'a');
      expect(r2.result, true);
      expect(r1.pos, 1);
      expect(r2.pos, 1);
    }

    {
      final p = Alpha1();
      const source = 'abc';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, 'abc');
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = Alpha1();
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {ErrorUnexpectedEndOfInput.message});
      expect(_errorsToSet(r2), {ErrorUnexpectedEndOfInput.message});
    }

    {
      final p = Alpha1();
      const source = '1';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {_errorUnexpectedCharacter(input, 0)});
      expect(_errorsToSet(r2), {_errorUnexpectedCharacter(input, 0)});
    }
  });
}

void _testAnd() {
  test('And', () async {
    {
      final p = And(Tag('~'));
      const source = '~123';
      const pos = 0;
      const result = null;
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = And(Tag('~'));
      const source = '123';
      const failPos = 0;
      const pos = 0;
      final errors = {
        _errorExpectedTags(['~']),
      };
      await _testFailure(p, source, failPos: failPos, pos: pos, errors: errors);
    }
  });
}

void _testBuffered() {
  test('Buffered', () async {
    {
      final p = Choice2(
        Buffered(Tuple4(Tag('0'), Tag('1'), Tag('2'), Tag('3'))),
        Tuple2(Tag('0'), Tag('1')),
      );
      const source = '01';
      const pos = 2;
      const result = ('0', '1');
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = Choice2(
        Buffered(Tuple4(Tag('0'), Tag('1'), Tag('2'), Tag('3'))),
        Tuple2(Tag('0'), Tag('1')),
      );
      const source = '012';
      const pos = 2;
      const result = ('0', '1');
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = Choice2(
        Buffered(Tuple4(Tag('0'), Tag('1'), Tag('2'), Tag('3'))),
        Tuple3(Tag('0'), Tag('1'), Tag('2')),
      );
      const source = '012';
      const pos = 3;
      const result = ('0', '1', '2');
      await _testSuccess(p, source, pos: pos, result: result);
    }
  });
}

void _testChar() {
  test('Char', () async {
    {
      final p = Char(0x30);
      const source = '0';
      const pos = 1;
      const result = 0x30;
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = Char(0x30);
      const source = '';
      const failPos = 0;
      const pos = 0;
      final errors = {
        ErrorUnexpectedEndOfInput.message,
        _errorExpectedCharacter(0x30)
      };
      await _testFailure(p, source, failPos: failPos, pos: pos, errors: errors);
    }

    {
      final p = Char(0x30);
      const source = '1';
      const failPos = 0;
      const pos = 0;
      final errors = {
        _errorExpectedCharacter(0x30),
      };
      await _testFailure(p, source, failPos: failPos, pos: pos, errors: errors);
    }

    {
      final p = Char(128512);
      const source = '😀';
      const pos = 2;
      const result = 128512;
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = Char(128512);
      const source = '';
      const failPos = 0;
      const pos = 0;
      final errors = {
        ErrorUnexpectedEndOfInput.message,
        _errorExpectedCharacter(128512),
      };
      await _testFailure(p, source, failPos: failPos, pos: pos, errors: errors);
    }

    {
      final p = Char(128512);
      const source = '1';
      const failPos = 0;
      const pos = 0;
      final errors = {
        _errorExpectedCharacter(128512),
      };
      await _testFailure(p, source, failPos: failPos, pos: pos, errors: errors);
    }
  });
}

void _testDigit() {
  test('Digit', () {
    {
      final p = Digit();
      const source = '1';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '1');
      expect(r2.result, true);
      expect(r1.pos, 1);
      expect(r2.pos, 1);
    }

    {
      final p = Digit();
      const source = '123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '123');
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = Digit();
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '');
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }

    {
      final p = Digit();
      const source = 'a';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '');
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }
  });
}

void _testDigit1() {
  test('Digit1', () {
    {
      final p = Digit1();
      const source = '1';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '1');
      expect(r2.result, true);
      expect(r1.pos, 1);
      expect(r2.pos, 1);
    }

    {
      final p = Digit1();
      const source = '123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '123');
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = Digit1();
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(r1.errors[0].toString(), ErrorUnexpectedEndOfInput.message);
      expect(r2.errors[0].toString(), ErrorUnexpectedEndOfInput.message);
    }

    {
      final p = Digit1();
      const source = 'a';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(r1.errors[0].toString(), _errorUnexpectedCharacter(input, 0));
      expect(r2.errors[0].toString(), _errorUnexpectedCharacter(input, 0));
    }
  });
}

Future<void> _testFailure<O>(
  Parser<StringReader, O> p,
  String source, {
  int failPos = 0,
  Set<String>? errors,
  int pos = 0,
  void Function(ParseResult<Object?, Object?> result)? testErrors,
}) async {
  final input = StringReader(source);
  final r0 = await _parseStream(p, _bufferSize, source);
  final r1 = tryParse(p.parse, input);
  final r2 = tryFastParse(p.fastParse, input);
  final rs = [r0, r1, r2];
  for (var i = 0; i < rs.length; i++) {
    final r = rs[i];
    if (i == 2) {
      expect(r.result, false);
    } else {
      expect(r.result != null, false);
    }

    expect(r.pos, pos);
    expect(r.failPos, failPos);
    if (errors != null) {
      expect(_errorsToSet(r), errors);
    }

    if (testErrors != null) {
      testErrors(r);
    }
  }
}

void _testHasMatch() {
  test('HasMatch', () {
    {
      final p = HasMatch(SkipWhile1(isAlpha));
      const source = '123abc456';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, (start: 3, end: 6, value: 'abc'));
      expect(r2.result, true);
      expect(r1.pos, 6);
      expect(r2.pos, 6);
    }

    {
      final p = HasMatch(SkipWhile1(isAlpha));
      const source = 'abc123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, (start: 0, end: 3, value: 'abc'));
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = HasMatch(SkipWhile1(isAlpha));
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {ErrorUnexpectedEndOfInput.message});
      expect(_errorsToSet(r2), {ErrorUnexpectedEndOfInput.message});
    }

    {
      final p = HasMatch(SkipWhile1(isAlpha));
      const source = '123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 2);
      expect(r2.failPos, 2);
      expect(_errorsToSet(r1), {
        _errorUnexpectedCharacter(input, 2),
      });
      expect(_errorsToSet(r2), {
        _errorUnexpectedCharacter(input, 2),
      });
    }
  });
}

void _testInteger() {
  test('Integer', () {
    {
      final p = Integer();
      const source = '0';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '0');
      expect(r2.result, true);
      expect(r1.pos, 1);
      expect(r2.pos, 1);
    }

    {
      final p = Integer();
      const source = '-0';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '-0');
      expect(r2.result, true);
      expect(r1.pos, 2);
      expect(r2.pos, 2);
    }

    {
      final p = Integer();
      const source = '-01';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '-0');
      expect(r2.result, true);
      expect(r1.pos, 2);
      expect(r2.pos, 2);
    }

    {
      final p = Integer();
      const source = '1';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '1');
      expect(r2.result, true);
      expect(r1.pos, 1);
      expect(r2.pos, 1);
    }

    {
      final p = Integer();
      const source = '-1';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '-1');
      expect(r2.result, true);
      expect(r1.pos, 2);
      expect(r2.pos, 2);
    }

    {
      final p = Integer();
      const source = '1234567890';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '1234567890');
      expect(r2.result, true);
      expect(r1.pos, 10);
      expect(r2.pos, 10);
    }

    {
      final p = Integer();
      const source = '-1234567890';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '-1234567890');
      expect(r2.result, true);
      expect(r1.pos, 11);
      expect(r2.pos, 11);
    }

    {
      final p = Integer();
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {ErrorUnexpectedEndOfInput.message});
      expect(_errorsToSet(r2), {ErrorUnexpectedEndOfInput.message});
    }

    {
      final p = Integer();
      const source = 'a';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {_errorUnexpectedCharacter(input, 0)});
      expect(_errorsToSet(r2), {_errorUnexpectedCharacter(input, 0)});
    }
  });
}

void _testMany() {
  test('Many', () async {
    {
      final p = Many(Tag('abc'));
      const source = '';
      const pos = 0;
      const result = <String>[];
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = Many(Tag('abc'));
      const source = 'abc';
      const pos = 3;
      const result = ['abc'];
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = Many(Tag('abc'));
      const source = 'abcabcdef';
      const pos = 6;
      const result = ['abc', 'abc'];
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = Many(Choice2(
        Tag('not'),
        Tag('no'),
      ));
      const source = 'nonotnonotno';
      const pos = 12;
      const result = ['no', 'not', 'no', 'not', 'no'];
      await _testSuccess(p, source, pos: pos, result: result);
    }
  });
}

void _testMany1() {
  test('Many1', () async {
    {
      final p = Many1(Tag('abc'));
      const source = 'abc';
      const pos = 3;
      const result = ['abc'];
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = Many1(Tag('abc'));
      const source = 'abcabcdef';
      const pos = 6;
      const result = ['abc', 'abc'];
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = Many1(Tag('abc'));
      const source = '';
      const failPos = 0;
      const pos = 0;
      final errors = {
        _errorExpectedTags(['abc']),
        ErrorUnexpectedEndOfInput.message,
      };
      await _testFailure(p, source, failPos: failPos, pos: pos, errors: errors);
    }

    {
      final p = Many1(Choice2(
        Tag('not'),
        Tag('no'),
      ));
      const source = '';
      const failPos = 0;
      const pos = 0;
      final errors = {
        _errorExpectedTags(['no', 'not']),
        ErrorUnexpectedEndOfInput.message,
      };
      await _testFailure(p, source, failPos: failPos, pos: pos, errors: errors);
    }
  });
}

void _testManyTill() {
  test('ManyTill', () {
    {
      final p = ManyTill(Tag('abc'), Tag('end'));
      const source = 'end';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, isA<(List<String>, String)>());
      expect(r1.result!.value.$1, <String>[]);
      expect(r1.result!.value.$2, 'end');
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = ManyTill(Tag('abc'), Tag('end'));
      const source = 'abcend';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, isA<(List<String>, String)>());
      expect(r1.result!.value.$1, ['abc']);
      expect(r1.result!.value.$2, 'end');
      expect(r2.result, true);
      expect(r1.pos, 6);
      expect(r2.pos, 6);
    }

    {
      final p = ManyTill(Tag('abc'), Tag('end'));
      const source = 'abcabcend';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, isA<(List<String>, String)>());
      expect(r1.result!.value.$1, ['abc', 'abc']);
      expect(r1.result!.value.$2, 'end');
      expect(r2.result, true);
      expect(r1.pos, 9);
      expect(r2.pos, 9);
    }

    {
      final p = ManyTill(Tag('abc'), Tag('end'));
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {
        _errorExpectedTags(['abc', 'end']),
        ErrorUnexpectedEndOfInput.message,
      });
      expect(_errorsToSet(r2), {
        _errorExpectedTags(['abc', 'end']),
        ErrorUnexpectedEndOfInput.message,
      });
    }

    {
      final p = ManyTill(Tag('abc'), Tag('end'));
      const source = '123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {
        _errorExpectedTags(['abc', 'end']),
      });
      expect(_errorsToSet(r2), {
        _errorExpectedTags(['abc', 'end']),
      });
    }

    {
      final p = ManyTill(Tag('abc'), Tag('end'));
      const source = 'abc';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.failPos, 3);
      expect(r2.failPos, 3);
      expect(_errorsToSet(r1), {
        _errorExpectedTags(['abc', 'end']),
        ErrorUnexpectedEndOfInput.message,
      });
      expect(_errorsToSet(r2), {
        _errorExpectedTags(['abc', 'end']),
        ErrorUnexpectedEndOfInput.message,
      });
    }

    {
      final p = ManyTill(Tag('abc'), Tag('end'));
      const source = 'abcabc';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.failPos, 6);
      expect(r2.failPos, 6);
      expect(_errorsToSet(r1), {
        _errorExpectedTags(['abc', 'end']),
        ErrorUnexpectedEndOfInput.message,
      });
      expect(_errorsToSet(r2), {
        _errorExpectedTags(['abc', 'end']),
        ErrorUnexpectedEndOfInput.message,
      });
    }
  });
}

void _testMatch1() {
  test('Match1', () {
    {
      final p = Match1(Char(0x30));
      const source = '0';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, (start: 0, end: 1, value: '0'));
      expect(r2.result, true);
      expect(r1.pos, 1);
      expect(r2.pos, 1);
    }

    {
      final p = Match1(Char(0x30));
      const source = '01';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, (start: 0, end: 1, value: '0'));
      expect(r2.result, true);
      expect(r1.pos, 1);
      expect(r2.pos, 1);
    }

    {
      final p = Match1(Char(0x30));
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {
        _errorExpectedCharacter(0x30),
        ErrorUnexpectedEndOfInput.message,
      });
      expect(_errorsToSet(r2), {
        _errorExpectedCharacter(0x30),
        ErrorUnexpectedEndOfInput.message,
      });
    }

    {
      final p = Alpha1();
      const source = '1';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {_errorUnexpectedCharacter(input, 0)});
      expect(_errorsToSet(r2), {_errorUnexpectedCharacter(input, 0)});
    }
  });
}

void _testReplaceAll() {
  test('ReplaceAll', () {
    {
      final p = ReplaceAll(
          Choice2(SkipWhile1(isAlpha), SkipWhile1(isDigit)), (e) => '');
      const source = '123abc456';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '');
      expect(r2.result, true);
      expect(r1.pos, 9);
      expect(r2.pos, 9);
    }

    {
      final p = ReplaceAll(
          Choice2(SkipWhile1(isAlpha), SkipWhile1(isDigit)), (e) => '');
      const source = '123!!!456';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '!!!');
      expect(r2.result, true);
      expect(r1.pos, 9);
      expect(r2.pos, 9);
    }

    {
      final p = ReplaceAll(
          Choice2(SkipWhile1(isAlpha), SkipWhile1(isDigit)), (e) => '');
      const source = '!!!abc!!!';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '!!!!!!');
      expect(r2.result, true);
      expect(r1.pos, 9);
      expect(r2.pos, 9);
    }

    {
      final p = ReplaceAll(
          Choice2(SkipWhile1(isAlpha), SkipWhile1(isDigit)), (e) => '');
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '');
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }

    {
      final p = ReplaceAll(
          Choice2(SkipWhile1(isAlpha), SkipWhile1(isDigit)), (e) => '');
      const source = '!!!';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '!!!');
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = ReplaceAll(Tag(''), (e) => '_');
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '_');
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }

    {
      final p = ReplaceAll(Tag(''), (e) => '_');
      const source = 'x';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '_x_');
      expect(r2.result, true);
      expect(r1.pos, 1);
      expect(r2.pos, 1);
    }
  });
}

void _testSatisfy() {
  test('Satisfy', () async {
    {
      final p = Satisfy((c) => c == 128512);
      const source = '😀1';
      const pos = 2;
      const result = 128512;
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = Satisfy((c) => c == 0x31);
      const source = '1';
      const pos = 1;
      const result = 0x31;
      await _testSuccess(p, source, pos: pos, result: result);
    }

    {
      final p = Satisfy((c) => c == 128512);
      const source = '';
      const failPos = 0;
      const pos = 0;
      final errors = {
        ErrorUnexpectedEndOfInput.message,
      };
      await _testFailure(p, source, failPos: failPos, pos: pos, errors: errors);
    }

    {
      final p = Satisfy((c) => c == 128512);
      const source = '123';
      final input = StringReader(source);
      const failPos = 0;
      const pos = 0;
      final errors = {
        _errorUnexpectedCharacter(input, 0),
      };
      await _testFailure(p, source, failPos: failPos, pos: pos, errors: errors);
    }
  });
}

void _testSeparatedList() {
  test('SeparatedList', () {
    {
      final p = SeparatedList(Tag('123'), Tag('.'));
      const source = '123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, ['123']);
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = SeparatedList(Tag('123'), Tag('.'));
      const source = '123.123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, ['123', '123']);
      expect(r2.result, true);
      expect(r1.pos, 7);
      expect(r2.pos, 7);
    }

    {
      final p = SeparatedList(Tag('123'), Tag('.'));
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, <String>[]);
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }
  });
}

void _testSeparatedList1() {
  test('SeparatedList1', () {
    {
      final p = SeparatedList1(Tag('123'), Tag('.'));
      const source = '123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, ['123']);
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = SeparatedList1(Tag('123'), Tag('.'));
      const source = '123.123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, ['123', '123']);
      expect(r2.result, true);
      expect(r1.pos, 7);
      expect(r2.pos, 7);
    }

    {
      final p = SeparatedList1(Tag('123'), Tag('.'));
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {
        _errorExpectedTags(['123']),
        ErrorUnexpectedEndOfInput.message,
      });
      expect(_errorsToSet(r2), {
        _errorExpectedTags(['123']),
        ErrorUnexpectedEndOfInput.message,
      });
    }
  });
}

void _testSeparatedListMN() {
  test('SeparatedListMN', () {
    {
      final p = SeparatedListMN(0, 0, Tag('123'), Tag('.'));
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, <String>[]);
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }

    {
      final p = SeparatedListMN(0, 1, Tag('123'), Tag('.'));
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, <String>[]);
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }

    {
      final p = SeparatedListMN(0, 1, Tag('123'), Tag('.'));
      const source = '123.123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, ['123']);
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = SeparatedListMN(1, 1, Tag('123'), Tag('.'));
      const source = '123.123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, ['123']);
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = SeparatedListMN(1, 2, Tag('123'), Tag('.'));
      const source = '123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, ['123']);
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = SeparatedListMN(1, 2, Tag('123'), Tag('.'));
      const source = '123.123.123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, ['123', '123']);
      expect(r2.result, true);
      expect(r1.pos, 7);
      expect(r2.pos, 7);
    }

    {
      final p = SeparatedListMN(1, 1, Tag('123'), Tag('.'));
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {
        _errorExpectedTags(['123']),
        ErrorUnexpectedEndOfInput.message,
      });
      expect(_errorsToSet(r2), {
        _errorExpectedTags(['123']),
        ErrorUnexpectedEndOfInput.message,
      });
    }

    {
      final p = SeparatedListMN(2, 2, Tag('123'), Tag('.'));
      const source = '123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
      expect(r1.failPos, 3);
      expect(r2.failPos, 3);
      expect(_errorsToSet(r1), {
        _errorExpectedTags(['.']),
        ErrorUnexpectedEndOfInput.message,
      });
      expect(_errorsToSet(r2), {
        _errorExpectedTags(['.']),
        ErrorUnexpectedEndOfInput.message,
      });
    }
  });
}

void _testSeparatedPair() {
  test('SeparatedPair', () {
    {
      final p = SeparatedPair(Tag('1'), Tag('2'), Tag('3'));
      const source = '123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, ('1', '3'));
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = SeparatedPair(Tag('1'), Tag('2'), Tag('3'));
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {
        _errorExpectedTags(['1']),
        ErrorUnexpectedEndOfInput.message,
      });
      expect(_errorsToSet(r2), {
        _errorExpectedTags(['1']),
        ErrorUnexpectedEndOfInput.message,
      });
    }
  });
}

void _testSkipWhile() {
  test('SkipWhile', () {
    {
      final p = SkipWhile((c) => c == 128512);
      const source = '😀';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '');
      expect(r2.result, true);
      expect(r1.pos, 2);
      expect(r2.pos, 2);
    }

    {
      final p = SkipWhile((c) => c == 128512 || c == 0x30);
      const source = '😀12';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '');
      expect(r2.result, true);
      expect(r1.pos, 2);
      expect(r2.pos, 2);
    }

    {
      final p = SkipWhile(isAlpha);
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '');
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }

    {
      final p = SkipWhile(isAlpha);
      const source = '123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '');
      expect(r2.result, true);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
    }
  });
}

void _testSkipWhile1() {
  test('SkipWhile1', () {
    {
      final p = SkipWhile1((c) => c == 128512);
      const source = '😀1';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, '');
      expect(r2.result, true);
      expect(r1.pos, 2);
      expect(r2.pos, 2);
    }

    {
      final p = SkipWhile1((c) => c == 128512);
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {
        ErrorUnexpectedEndOfInput.message,
      });
      expect(_errorsToSet(r2), {
        ErrorUnexpectedEndOfInput.message,
      });
    }

    {
      final p = SkipWhile1(isAlpha);
      const source = '123';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {
        _errorUnexpectedCharacter(input, 0),
      });
      expect(_errorsToSet(r2), {
        _errorUnexpectedCharacter(input, 0),
      });
    }
  });
}

Future<void> _testSuccess<O>(
  Parser<StringReader, O> p,
  String source, {
  int pos = 0,
  Object? result,
  void Function(Object? result)? testResult,
}) async {
  final input = StringReader(source);
  final r0 = await _parseStream<O>(p, _bufferSize, source);
  final r1 = tryParse(p.parse, input);
  final r2 = tryFastParse(p.fastParse, input);
  final rs = [r0, r1, r2];
  for (var i = 0; i < rs.length; i++) {
    final r = rs[i];
    if (i == 2) {
      expect(r.result, true);
    } else {
      expect(r.result != null, true);
      if (testResult != null) {
        testResult((r.result as Result).value);
      } else {
        expect((r.result as Result).value, result);
      }
    }

    expect(r.pos, pos);
  }
}

void _testTag() {
  test('Tag', () async {
    {
      for (var i = 1; i < 10; i++) {
        final tag = String.fromCharCodes(List.generate(i, (i) => i + 0x30));
        final p = Tag(tag);
        final source = tag;
        final result = tag;
        final pos = tag.length;
        await _testSuccess(p, source, pos: pos, result: result);
      }
    }

    {
      final p = Tag('abc');
      const source = '';
      const failPos = 0;
      const pos = 0;
      final errors = {
        ErrorUnexpectedEndOfInput.message,
        _errorExpectedTags(['abc']),
      };
      await _testFailure(p, source, failPos: failPos, pos: pos, errors: errors);
    }

    {
      final p = Tag('abc');
      const source = '1';
      const failPos = 0;
      const pos = 0;
      final errors = {
        _errorExpectedTags(['abc']),
      };
      await _testFailure(p, source, failPos: failPos, pos: pos, errors: errors);
    }
  });
}

void _testTags() {
  test('Tags', () {
    {
      final p = Tags(['abc', 'def']);
      const source = 'abc';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, 'abc');
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = Tags(['abc', 'def']);
      const source = 'def';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, true);
      expect(r1.result!.value, 'def');
      expect(r2.result, true);
      expect(r1.pos, 3);
      expect(r2.pos, 3);
    }

    {
      final p = Tags(['abc', 'def']);
      const source = '';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {
        ErrorUnexpectedEndOfInput.message,
        _errorExpectedTags(['abc', 'def']),
      });
      expect(_errorsToSet(r2), {
        ErrorUnexpectedEndOfInput.message,
        _errorExpectedTags(['abc', 'def']),
      });
    }

    {
      final p = Tags(['abc', 'def']);
      const source = 'ab';
      final input = StringReader(source);
      final r1 = tryParse(p.parse, input);
      final r2 = tryFastParse(p.fastParse, input);
      expect(r1.result != null, false);
      expect(r2.result, false);
      expect(r1.pos, 0);
      expect(r2.pos, 0);
      expect(r1.failPos, 0);
      expect(r2.failPos, 0);
      expect(_errorsToSet(r1), {
        _errorExpectedTags(['abc', 'def']),
      });
      expect(_errorsToSet(r2), {
        _errorExpectedTags(['abc', 'def']),
      });
    }
  });
}
