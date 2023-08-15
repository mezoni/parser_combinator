import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Eof extends Parser<StringReader, Object?> {
  const Eof({String? name}) : super(name);

  @override
  Parser<StringReader, Object?> build(ParserBuilder<StringReader> builder) {
    return Eof(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    if (state.pos >= state.input.length) {
      return true;
    }

    state.fail<Object?>(const ErrorExpectedEndOfInput());
    return false;
  }

  @override
  Result<Object?>? parse(State<StringReader> state) {
    if (state.pos >= state.input.length) {
      return const Result(null);
    }

    return state.fail(const ErrorExpectedEndOfInput());
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, VoidCallback1<Object?> onDone) {
    final p = _AsyncEofParser();
    p.parseAsync(state, onDone);
  }
}

class _AsyncEofParser extends ChunkedDataParser<Object?> {
  var eof = true;

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(const ErrorExpectedEndOfInput());
  }

  @override
  bool? parseChar(int c) {
    eof = false;
    return false;
  }

  @override
  bool parseError() {
    result = Result(null);
    return eof;
  }
}
