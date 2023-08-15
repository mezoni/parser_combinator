import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class SkipWhile1 extends Parser<StringReader, String> {
  final Predicate<int> f;

  const SkipWhile1(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return SkipWhile1(name: name, f);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!f(c)) {
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

  @override
  Result<String>? parse(State<StringReader> state) {
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
        ? const Result('')
        : state.fail(const ErrorUnexpectedCharacter());
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final p = _AsyncSkipWhile1Parser(f);
    p.parseAsync(state, onDone);
  }
}

class _AsyncSkipWhile1Parser extends ChunkedDataParser<String> {
  int count = 0;

  final Predicate<int> f;

  _AsyncSkipWhile1Parser(this.f);

  int? c;

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(ErrorUnexpectedCharacter(c));
  }

  @override
  bool? parseChar(int c) {
    if (f(c)) {
      count++;
      return null;
    }

    this.c = c;
    return false;
  }

  @override
  bool parseError() {
    if (count == 0) {
      return false;
    }

    result = Result('');
    return true;
  }
}
