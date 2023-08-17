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
      State<ChunkedData<StringReader>> state, ResultCallback<Object?> onDone) {
    if (!backtrack(state)) {
      onDone(null);
      return;
    }

    final input = state.input;
    void parse() {
      if (input.isIncomplete(state.pos)) {
        input.sleep = true;
        input.handle(parse);
        return;
      }

      if (input.isEnd(state.pos)) {
        onDone(Result(null));
      } else {
        state.fail<Object?>(const ErrorExpectedEndOfInput());
        onDone(null);
      }

      return;
    }

    parse();
  }
}
