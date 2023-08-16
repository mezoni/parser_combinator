import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class AnyChar extends Parser<StringReader, int> {
  const AnyChar({String? name}) : super(name);

  @override
  Parser<StringReader, int> build(ParserBuilder<StringReader> builder) {
    return AnyChar(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    if (state.pos < input.length) {
      input.readChar(state.pos);
      state.pos += input.count;
      return true;
    }

    state.fail<Object?>(ErrorUnexpectedEndOfInput());
    return false;
  }

  @override
  Result<int>? parse(State<StringReader> state) {
    final input = state.input;
    if (state.pos < input.length) {
      final c = input.readChar(state.pos);
      state.pos += input.count;
      return Result(c);
    }

    return state.fail(ErrorUnexpectedEndOfInput());
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, ResultCallback<int> onDone) {
    if (!backtrack(state)) {
      onDone(null);
      return;
    }

    final input = state.input;
    input.buffering++;
    bool parse() {
      final data = input.data;
      final start = input.start;
      final end = start + data.length;
      if (state.pos < end) {
        final c = data.readChar(state.pos - start);
        state.pos += data.count;
        input.buffering--;
        onDone(Result(c));
        return true;
      }

      if (!input.isClosed) {
        input.listen(parse);
        return false;
      }

      state.fail<Object?>(const ErrorUnexpectedEndOfInput());
      input.buffering--;
      onDone(null);
      return true;
    }

    parse();
  }
}
