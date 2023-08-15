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
    final input = state.input;
    final buffer = input.buffer;
    final position = input.position;
    final index = input.index;
    final pos = state.pos;
    input.buffering++;
    bool parse() {
      var i = input.position - input.start;
      if (i < 0) {
        input.buffering--;
        input.position = position;
        input.index = index;
        state.failAt<Object?>(state.failPos, ErrorBacktrackingError(state.pos));
        onDone(null);
        return true;
      }

      while (i < buffer.length) {
        final chunk = buffer[i];
        if (input.index >= chunk.length) {
          i++;
          input.position++;
          input.index = 0;
          continue;
        }

        input.buffering--;
        input.position = position;
        input.index = index;
        state.pos = pos;
        state.fail<Object?>(const ErrorExpectedEndOfInput());
        onDone(null);
        return true;
      }

      if (input.isClosed) {
        input.buffering--;
        input.position = position;
        input.index = index;
        onDone(Result(null));
        return true;
      }

      input.listen(parse);
      return false;
    }

    parse();
  }
}
