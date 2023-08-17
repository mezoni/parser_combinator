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
  void parseAsync(
      State<ChunkedData<StringReader>> state, ResultCallback<int> onDone) {
    if (!backtrack(state)) {
      onDone(null);
      return;
    }

    final input = state.input;
    input.buffering++;
    void parse() {
      if (input.isIncomplete(state.pos)) {
        input.sleep = true;
        input.handle(parse);
        return;
      }

      final data = input.data;
      input.buffering--;
      if (!input.isEnd(state.pos)) {
        final source = data.source!;
        final c = source.runeAt(state.pos - input.start);
        if (c == char) {
          state.pos += c > 0xffff ? 2 : 1;
          onDone(Result(c));
          return;
        }
      }

      state.fail<Object?>(ErrorExpectedCharacter(char));
      onDone(null);
    }

    parse();
  }
}
