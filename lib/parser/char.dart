import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Char extends Parser<StringReader, int> {
  final int char;

  const Char(this.char, {String? name}) : super(name);

  @override
  Parser<StringReader, int> build(ParserBuilder<StringReader> builder) {
    return Char(name: name, char);
  }

  @override
  bool fastParse(State<StringReader> state) {
    if (char < 0 || char > 0x10ffff) {
      throw RangeError.range(char, 0, 0x10ffff);
    }

    final input = state.input;
    if (state.pos < input.length) {
      if (input.readChar(state.pos) == char) {
        state.pos += input.count;
        return true;
      }
    }

    state.fail<Object?>(ErrorExpectedCharacter(char));
    return false;
  }

  @override
  Result<int>? parse(State<StringReader> state) {
    if (char < 0 || char > 0x10ffff) {
      throw RangeError.range(char, 0, 0x10ffff);
    }

    final input = state.input;
    if (state.pos < input.length) {
      if (input.readChar(state.pos) == char) {
        state.pos += input.count;
        return Result(char);
      }
    }

    return state.fail(ErrorExpectedCharacter(char));
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
        if (c == char) {
          state.pos += c > 0xffff ? 2 : 1;
          result.value = Result(c);
          result.ok = true;
          input.handler = result.handler;
          return;
        }
      }

      result.ok = false;
      state.fail<Object?>(ErrorExpectedCharacter(char));
      input.handler = result.handler;
    }

    parse();
    return result;
  }
}
