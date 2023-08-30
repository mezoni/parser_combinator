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
  AsyncResult<Object?> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<Object?>();
    if (!backtrack(state)) {
      result.ok = false;
      return result;
    }

    final input = state.input;
    final end = input.end;
    if (state.pos < end) {
      state.fail<Object?>(const ErrorExpectedEndOfInput());
      result.ok = false;
      input.handler = result.handler;
      return result;
    }

    void parse() {
      final end = input.end;
      if (state.pos >= end && !input.isClosed) {
        input.sleep = true;
        input.handler = parse;
        return;
      }

      if (result.ok = state.pos >= end) {
        result.value = const Result<Object?>(null);
      } else {
        state.fail<Object?>(const ErrorExpectedEndOfInput());
      }

      input.handler = result.handler;
    }

    parse();
    return result;
  }
}
