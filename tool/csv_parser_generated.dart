// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:parser_combinator/extra/csv_parser.dart' as _i0;
import 'package:parser_combinator/runtime.dart';

bool _eof(State<StringReader> state) {
  if (state.pos >= state.input.length) {
    return true;
  }

  state.fail<Object?>(const ErrorExpectedEndOfInput());
  return false;
}

bool _not0(State<StringReader> state) {
  final pos = state.pos;
  final r = _eof(state);
  if (!r) {
    return true;
  }

  state.pos = pos;
  state.fail<Object?>(ErrorUnexpectedInput(pos - state.pos));
  return false;
}

bool _eol(State<StringReader> state) {
  const tags = ['\n', '\r\n', '\r'];
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

bool _rowEnding(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _eol(state);
  if (r1) {
    final r2 = _not0(state);
    if (r2) {
      return true;
    }
  }

  state.pos = pos;
  return false;
}

bool _tag0(State<StringReader> state) {
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

Result<String>? _text(State<StringReader> state) {
  const f = _i0.isTextChar;
  final input = state.input;
  final pos = state.pos;
  while (state.pos < input.length) {
    final c = input.readChar(state.pos);
    if (!f(c)) {
      break;
    }

    state.pos += input.count;
  }

  return state.pos != pos
      ? Result(input.substring(pos, state.pos))
      : const Result('');
}

bool _quote(State<StringReader> state) {
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

bool _openQuote(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _ws(state);
  if (r1) {
    final r2 = _quote(state);
    if (r2) {
      return true;
    }
  }

  state.pos = pos;
  return false;
}

bool _tag1(State<StringReader> state) {
  const tag = '""';
  final input = state.input;
  final pos = state.pos;
  if (input.startsWith(tag, pos)) {
    state.pos += input.count;
    return true;
  }

  state.fail<Object?>(ErrorExpectedTag(tag));
  return false;
}

Result<int>? _valueP0(State<StringReader> state) {
  const value = 34;
  final r = _tag1(state);
  if (r) {
    return Result(value);
  }

  return null;
}

Result<int>? _satisfy0(State<StringReader> state) {
  const f = _i0.isNotQuote;
  final input = state.input;
  if (state.pos < input.length) {
    final c = input.readChar(state.pos);
    if (f(c)) {
      state.pos += input.count;
      return Result(c);
    }
  }

  return state.fail(ErrorUnexpectedCharacter());
}

Result<int>? _choice2_0(State<StringReader> state) {
  final r1 = _satisfy0(state);
  if (r1 != null) {
    return r1;
  }

  final r2 = _valueP0(state);
  if (r2 != null) {
    return r2;
  }

  return null;
}

Result<List<int>>? _many0(State<StringReader> state) {
  final r = _choice2_0(state);
  if (r == null) {
    return Result([]);
  }

  final list = [r.value];
  while (true) {
    final r = _choice2_0(state);
    if (r == null) {
      return Result(list);
    }

    list.add(r.value);
  }
}

bool _closeQuote(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _quote(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }
  }

  state.pos = pos;
  return false;
}

Result<List<int>>? _delimited0(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _openQuote(state);
  if (r1) {
    final r2 = _many0(state);
    if (r2 != null) {
      final r3 = _closeQuote(state);
      if (r3) {
        return r2;
      }
    }
  }

  state.pos = pos;
  return null;
}

Result<String>? _map1_0(State<StringReader> state) {
  const f = String.fromCharCodes;
  final r = _delimited0(state);
  if (r != null) {
    final v = f(r.value);
    return Result(v);
  }

  return null;
}

Result<String>? _malformed0(State<StringReader> state) {
  const message = 'Untermnated string';
  final failPos = state.failPos;
  final errorCount = state.errorCount;
  final r = _map1_0(state);
  if (r != null) {
    return r;
  }

  if (state.canHandleError(failPos, errorCount)) {
    if (state.pos != failPos) {
      state.clearErrors(failPos, errorCount);
      state.failAt<Object?>(
          state.failPos, ErrorMessage(state.pos - state.failPos, message));
    }
  }

  return null;
}

Result<String>? _field(State<StringReader> state) {
  final r1 = _malformed0(state);
  if (r1 != null) {
    return r1;
  }

  final r2 = _text(state);
  if (r2 != null) {
    return r2;
  }

  return null;
}

Result<List<String>>? _row(State<StringReader> state) {
  final r1 = _field(state);
  if (r1 == null) {
    return null;
  }

  final list = [r1.value];
  while (true) {
    final r2 = _tag0(state);
    if (!r2) {
      return Result(list);
    }

    final r3 = _field(state);
    if (r3 == null) {
      return null;
    }

    list.add(r3.value);
  }
}

Result<List<List<String>>>? _separatedList1_0(State<StringReader> state) {
  final r1 = _row(state);
  if (r1 == null) {
    return null;
  }

  final list = [r1.value];
  while (true) {
    final r2 = _rowEnding(state);
    if (!r2) {
      return Result(list);
    }

    final r3 = _row(state);
    if (r3 == null) {
      return null;
    }

    list.add(r3.value);
  }
}

bool _opt0(State<StringReader> state) {
  _eol(state);
  return true;
}

Result<List<List<String>>>? _rows(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _separatedList1_0(state);
  if (r1 != null) {
    final r2 = _opt0(state);
    if (r2) {
      return r1;
    }

    state.pos = pos;
  }

  return null;
}

Result<List<List<String>>>? parser(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _rows(state);
  if (r1 != null) {
    final r2 = _eof(state);
    if (r2) {
      return r1;
    }

    state.pos = pos;
  }

  return null;
}
