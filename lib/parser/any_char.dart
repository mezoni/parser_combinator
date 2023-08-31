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
  AsyncResult<int> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<int>();
    if (!backtrack(state)) {
      result.ok = false;
      return result;
    }

    final input = state.input;
    input.buffering++;
    void parse() {
      final end = input.end;
      if (state.pos >= end && !input.isClosed) {
        input.sleep = true;
        input.handler = parse;
        return;
      }

      final data = input.data;
      input.buffering--;
      if (state.pos < end) {
        final source = data.source;
        final c = source.runeAt(state.pos - input.start);
        state.pos += c > 0xffff ? 2 : 1;
        result.value = Result(c);
        result.ok = true;
        input.handler = result.handler;
        return;
      }

      result.ok = false;
      state.fail<Object?>(const ErrorUnexpectedEndOfInput());
      input.handler = result.handler;
    }

    parse();
    return result;
  }
}
