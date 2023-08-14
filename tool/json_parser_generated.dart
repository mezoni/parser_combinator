// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:parser_combinator/extra/json_parser.dart' as _i1;
import 'package:parser_combinator/parser/predicate.dart' as _i0;
import 'package:parser_combinator/runtime.dart';

bool _ws(State<StringReader> state) {
  const f = _i0.isWhitespace;
  final input = state.input;
  while (state.pos < input.length) {
    final c = input.readChar(state.pos);
    if (!f(c)) {
      break;
    }

    state.pos += input.count;
  }

  return true;
}

bool _tag0(State<StringReader> state) {
  const tag = 'true';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

bool _terminated0(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag0(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }

    state.pos = pos;
  }

  return false;
}

Result<bool>? _true(State<StringReader> state) {
  const value = true;
  final r = _terminated0(state);
  if (r) {
    return Result(value);
  }

  return null;
}

bool _tag1(State<StringReader> state) {
  const tag = 'null';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

bool _terminated1(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag1(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }

    state.pos = pos;
  }

  return false;
}

Result<Object?>? _null(State<StringReader> state) {
  const value = null;
  final r = _terminated1(state);
  if (r) {
    return Result(value);
  }

  return null;
}

bool _tag2(State<StringReader> state) {
  const tag = 'false';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

bool _terminated2(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag2(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }

    state.pos = pos;
  }

  return false;
}

Result<bool>? _false(State<StringReader> state) {
  const value = false;
  final r = _terminated2(state);
  if (r) {
    return Result(value);
  }

  return null;
}

bool _digit1_0(State<StringReader> state) {
  final input = state.input;
  final pos = state.pos;
  while (state.pos < input.length) {
    final c = input.readChar(state.pos);
    if (!(c >= 0x30 && c <= 0x39)) {
      break;
    }

    state.pos += input.count;
  }

  if (state.pos != pos) {
    return true;
  }

  state.fail<Object?>(const ErrorUnexpectedCharacter());
  return false;
}

bool _digit1(State<StringReader> state) {
  const tag = 'decimal digit';
  final failPos = state.failPos;
  final errorCount = state.errorCount;
  final r = _digit1_0(state);
  if (r) {
    return true;
  }

  if (state.canHandleError(failPos, errorCount)) {
    if (state.pos == state.failPos) {
      state.clearErrors(failPos, errorCount);
      state.fail<Object?>(ErrorExpectedTag(tag));
    }
  }

  return false;
}

bool _tags0(State<StringReader> state) {
  const tags = ['-', '+'];
  final input = state.input;
  for (var i = 0; i < tags.length; i++) {
    final tag = tags[i];
    if (input.startsWith(tag, state.pos)) {
      state.pos += input.count;
      return true;
    }
  }

  state.fail<Object?>(ErrorExpectedTags(tags));
  return false;
}

bool _opt1(State<StringReader> state) {
  _tags0(state);
  return true;
}

bool _tags1(State<StringReader> state) {
  const tags = ['E', 'e'];
  final input = state.input;
  for (var i = 0; i < tags.length; i++) {
    final tag = tags[i];
    if (input.startsWith(tag, state.pos)) {
      state.pos += input.count;
      return true;
    }
  }

  state.fail<Object?>(ErrorExpectedTags(tags));
  return false;
}

bool _exponent(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tags1(state);
  if (r1) {
    final r2 = _opt1(state);
    if (r2) {
      final r3 = _digit1(state);
      if (r3) {
        return true;
      }
    }
  }

  state.pos = pos;
  return false;
}

bool _opt0(State<StringReader> state) {
  _exponent(state);
  return true;
}

bool _tag3(State<StringReader> state) {
  const tag = '.';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

bool _fraction(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag3(state);
  if (r1) {
    final r2 = _digit1(state);
    if (r2) {
      return true;
    }
  }

  state.pos = pos;
  return false;
}

bool _opt2(State<StringReader> state) {
  _fraction(state);
  return true;
}

bool _integer(State<StringReader> state) {
  final pos = state.pos;
  final input = state.input;
  final length = input.length;
  var ok = false;
  int readChar() {
    if (state.pos < length) {
      return input.readChar(state.pos);
    }

    return -1;
  }

  while (true) {
    var c = readChar();
    if (c == 0x2d) {
      state.pos += input.count;
      c = readChar();
    }

    if (c == 0x30) {
      state.pos += input.count;
      ok = true;
      break;
    }

    if (!(c >= 0x31 && c <= 0x39)) {
      break;
    }

    ok = true;
    state.pos += input.count;
    while (true) {
      c = readChar();
      if (!(c >= 0x30 && c <= 0x39)) {
        break;
      }

      state.pos += input.count;
    }

    break;
  }

  if (!ok) {
    state.pos = pos;
    state.fail<Object?>(const ErrorUnexpectedCharacter());
  }

  return ok;
}

bool _fast3_0(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _integer(state);
  if (r1) {
    final r2 = _opt2(state);
    if (r2) {
      final r3 = _opt0(state);
      if (r3) {
        return true;
      }
    }
  }

  state.pos = pos;
  return false;
}

Result<String>? _recognize0(State<StringReader> state) {
  final pos = state.pos;
  final r = _fast3_0(state);
  if (r) {
    return state.pos != pos
        ? Result(state.input.substring(pos, state.pos))
        : Result('');
  }

  return null;
}

Result<num>? _number_(State<StringReader> state) {
  const f = num.parse;
  final r = _recognize0(state);
  if (r != null) {
    final v = f(r.value);
    return Result(v);
  }

  return null;
}

Result<num>? _terminated3(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _number_(state);
  if (r1 != null) {
    final r2 = _ws(state);
    if (r2) {
      return r1;
    }

    state.pos = pos;
  }

  return null;
}

Result<num>? _number(State<StringReader> state) {
  const tag = 'number';
  final failPos = state.failPos;
  final errorCount = state.errorCount;
  final r = _terminated3(state);
  if (r != null) {
    return r;
  }

  if (state.canHandleError(failPos, errorCount)) {
    if (state.pos == state.failPos) {
      state.clearErrors(failPos, errorCount);
      state.fail<Object?>(ErrorExpectedTag(tag));
    }
  }

  return null;
}

bool _tag4(State<StringReader> state) {
  const tag = '"';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

bool _tag5(State<StringReader> state) {
  const tag = 'u';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

Result<String>? _hexValue(State<StringReader> state) {
  const f = _i0.isHexDigit;
  const m = 4;
  const n = 4;
  if (m > n) {
    throw RangeError.range(m, 0, n, 'm');
  }

  final input = state.input;
  final pos = state.pos;
  var count = 0;
  while (count < n && state.pos < input.length) {
    final c = input.readChar(state.pos);
    final v = f(c);
    if (!v) {
      break;
    }

    state.pos += input.count;
    count++;
  }

  if (count >= m) {
    return state.pos != pos
        ? Result(input.substring(pos, state.pos))
        : const Result('');
  }

  final failPos = state.pos;
  state.pos = pos;
  return state.failAt(failPos, const ErrorUnexpectedCharacter());
}

Result<String>? _hexValueChecked(State<StringReader> state) {
  const message = 'Expected 4 digit hexadecimal number';
  final failPos = state.failPos;
  final errorCount = state.errorCount;
  final r = _hexValue(state);
  if (r != null) {
    return r;
  }

  if (state.canHandleError(failPos, errorCount)) {
    if (state.pos != state.failPos) {
      state.clearErrors(failPos, errorCount);
      state.failAt<Object?>(
          state.failPos, ErrorMessage(state.pos - state.failPos, message));
    }
  }

  return null;
}

Result<String>? _preceded0(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag5(state);
  if (r1) {
    final r2 = _hexValueChecked(state);
    if (r2 != null) {
      return r2;
    }

    state.pos = pos;
  }

  return null;
}

Result<String>? _escapeHexValue(State<StringReader> state) {
  const f = _i1.createStringFromHexValue;
  final r = _preceded0(state);
  if (r != null) {
    final v = f(r.value);
    return Result(v);
  }

  return null;
}

Result<String>? _escape(State<StringReader> state) {
  final input = state.input;
  final c = input.readChar(state.pos);
  switch (c) {
    case 34:
      state.pos += input.count;
      return const Result('"');
    case 0x2F:
      state.pos += input.count;
      return const Result('/');
    case 0x5C:
      state.pos += input.count;
      return const Result(r'\\');
    case 0x62:
      state.pos += input.count;
      return const Result('\b');
    case 0x66:
      state.pos += input.count;
      return const Result('\f');
    case 0x6E:
      state.pos += input.count;
      return const Result('\n');
    case 0x72:
      state.pos += input.count;
      return const Result('\r');
    case 0x74:
      state.pos += input.count;
      return const Result('\t');
  }

  return state.fail(const ErrorUnexpectedCharacter());
}

Result<String>? _choice2_0(State<StringReader> state) {
  final r1 = _escape(state);
  if (r1 != null) {
    return r1;
  }

  final r2 = _escapeHexValue(state);
  if (r2 != null) {
    return r2;
  }

  return null;
}

Result<String>? _stringChars0(State<StringReader> state) {
  const isNormalChar = _i1.isNormalChar;
  const controlChar = 92;
  final input = state.input;
  final list = <String>[];
  var str = '';
  while (state.pos < input.length) {
    final pos = state.pos;
    str = '';
    var c = -1;
    while (state.pos < input.length) {
      c = input.readChar(state.pos);
      final ok = isNormalChar(c);
      if (!ok) {
        break;
      }

      state.pos += input.count;
    }

    if (state.pos != pos) {
      str = input.substring(pos, state.pos);
      if (list.isNotEmpty) {
        list.add(str);
      }
    }

    if (c != controlChar) {
      break;
    }

    state.pos += 1;
    final r = _choice2_0(state);
    if (r == null) {
      state.pos = pos;
      break;
    }

    if (list.isEmpty && str != '') {
      list.add(str);
    }

    list.add(r.value);
  }

  if (list.isEmpty) {
    return Result(str);
  }

  return Result(list.join());
}

bool _doubleQuote(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag4(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }

    state.pos = pos;
  }

  return false;
}

Result<String>? _delimited0(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag4(state);
  if (r1) {
    final r2 = _stringChars0(state);
    if (r2 != null) {
      final r3 = _doubleQuote(state);
      if (r3) {
        return r2;
      }
    }
  }

  state.pos = pos;
  return null;
}

Result<String>? _string(State<StringReader> state) {
  const tag = 'string';
  final failPos = state.failPos;
  final errorCount = state.errorCount;
  final r = _delimited0(state);
  if (r != null) {
    return r;
  }

  if (state.canHandleError(failPos, errorCount)) {
    if (state.pos == state.failPos) {
      state.clearErrors(failPos, errorCount);
      state.fail<Object?>(ErrorExpectedTag(tag));
    }
  }

  return null;
}

bool _tag6(State<StringReader> state) {
  const tag = '[';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

bool _openBracket(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag6(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }

    state.pos = pos;
  }

  return false;
}

bool _tag7(State<StringReader> state) {
  const tag = ',';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

bool _comma(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag7(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }

    state.pos = pos;
  }

  return false;
}

Result<List<Object?>>? _values(State<StringReader> state) {
  final r1 = _value(state);
  if (r1 == null) {
    return const Result([]);
  }

  final list = [r1.value];
  while (true) {
    final r2 = _comma(state);
    if (!r2) {
      return Result(list);
    }

    final r3 = _value(state);
    if (r3 == null) {
      return null;
    }

    list.add(r3.value);
  }
}

bool _tag8(State<StringReader> state) {
  const tag = ']';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

bool _closeBracket(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag8(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }

    state.pos = pos;
  }

  return false;
}

Result<List<Object?>>? _array(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _openBracket(state);
  if (r1) {
    final r2 = _values(state);
    if (r2 != null) {
      final r3 = _closeBracket(state);
      if (r3) {
        return r2;
      }
    }
  }

  state.pos = pos;
  return null;
}

bool _tag9(State<StringReader> state) {
  const tag = '{';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

bool _openBrace(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag9(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }

    state.pos = pos;
  }

  return false;
}

bool _tag10(State<StringReader> state) {
  const tag = ':';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

bool _colon(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag10(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }

    state.pos = pos;
  }

  return false;
}

Result<(String, Object?)>? _separatedPair0(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _string(state);
  if (r1 != null) {
    final r2 = _colon(state);
    if (r2) {
      final r3 = _value(state);
      if (r3 != null) {
        return Result((r1.value, r3.value));
      }
    }
  }

  state.pos = pos;
  return null;
}

Result<MapEntry<String, Object?>>? _keyValue(State<StringReader> state) {
  const f = _i1.createMapEntry;
  final r = _separatedPair0(state);
  if (r != null) {
    final v = f(r.value);
    return Result(v);
  }

  return null;
}

Result<List<MapEntry<String, Object?>>>? _keyValues(State<StringReader> state) {
  final r1 = _keyValue(state);
  if (r1 == null) {
    return const Result([]);
  }

  final list = [r1.value];
  while (true) {
    final r2 = _comma(state);
    if (!r2) {
      return Result(list);
    }

    final r3 = _keyValue(state);
    if (r3 == null) {
      return null;
    }

    list.add(r3.value);
  }
}

bool _tag11(State<StringReader> state) {
  const tag = '}';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

bool _closeBrace(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag11(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }

    state.pos = pos;
  }

  return false;
}

Result<List<MapEntry<String, Object?>>>? _delimited1(
    State<StringReader> state) {
  final pos = state.pos;
  final r1 = _openBrace(state);
  if (r1) {
    final r2 = _keyValues(state);
    if (r2 != null) {
      final r3 = _closeBrace(state);
      if (r3) {
        return r2;
      }
    }
  }

  state.pos = pos;
  return null;
}

Result<Map<dynamic, dynamic>>? _object(State<StringReader> state) {
  const f = Map.fromEntries;
  final r = _delimited1(state);
  if (r != null) {
    final v = f(r.value);
    return Result(v);
  }

  return null;
}

Result<Object?>? _value(State<StringReader> state) {
  final r1 = _object(state);
  if (r1 != null) {
    return r1;
  }

  final r2 = _array(state);
  if (r2 != null) {
    return r2;
  }

  final r3 = _string(state);
  if (r3 != null) {
    return r3;
  }

  final r4 = _number(state);
  if (r4 != null) {
    return r4;
  }

  final r5 = _false(state);
  if (r5 != null) {
    return r5;
  }

  final r6 = _null(state);
  if (r6 != null) {
    return r6;
  }

  final r7 = _true(state);
  if (r7 != null) {
    return r7;
  }

  return null;
}

bool _eof0(State<StringReader> state) {
  if (state.pos >= state.input.length) {
    return true;
  }

  state.fail<Object?>(const ErrorExpectedEndOfInput());
  return false;
}

Result<Object?>? parser(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _ws(state);
  if (r1) {
    final r2 = _value(state);
    if (r2 != null) {
      final r3 = _eof0(state);
      if (r3) {
        return r2;
      }
    }
  }

  state.pos = pos;
  return null;
}
