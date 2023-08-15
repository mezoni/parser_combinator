import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class TakeWhile1 extends Parser<StringReader, String> {
  final Predicate<int> f;

  const TakeWhile1(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return TakeWhile1(name: name, f);
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
        ? Result(input.substring(pos, state.pos))
        : state.fail(const ErrorUnexpectedCharacter());
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final p = _AsyncTakeWhile1Parser(f);
    p.parseAsync(state, onDone);
  }
}

class _AsyncTakeWhile1Parser extends ChunkedDataParser<String> {
  final List<int> charCodes = [];

  final Predicate<int> f;

  _AsyncTakeWhile1Parser(this.f);

  int? c;

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(ErrorUnexpectedCharacter(c));
  }

  @override
  bool? parseChar(int c) {
    if (f(c)) {
      charCodes.add(c);
      return null;
    }

    this.c = c;
    return false;
  }

  @override
  bool parseError() {
    if (charCodes.isEmpty) {
      return false;
    }

    final value = String.fromCharCodes(charCodes);
    result = Result(value);
    return true;
  }
}
