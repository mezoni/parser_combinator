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
      State<ChunkedData<StringReader>> state, VoidCallback1<int> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final pos = state.pos;
    final position = input.position;
    final index = input.index;
    input.buffering++;
    bool parse() {
      var i = input.position - input.start;
      if (i < 0) {
        input.buffering--;
        input.position = position;
        input.index = index;
        state.failAt<Object?>(state.failPos, ErrorBacktrackingError(state.pos));
        state.pos = pos;
        onDone(null);
        return true;
      }

      var ok = true;
      while (i < buffer.length) {
        final chunk = buffer[i];
        if (input.index >= chunk.length) {
          i++;
          input.position++;
          input.index = 0;
          continue;
        }

        final c = chunk.readChar(input.index);
        if (c != char) {
          ok = false;
          break;
        }

        input.index += chunk.count;
        state.pos += chunk.count;
        input.buffering--;
        onDone(Result(char));
        return true;
      }

      if (!ok || input.isClosed) {
        input.buffering--;
        input.position = position;
        input.index = index;
        state.pos = pos;
        state.fail<Object?>(ErrorExpectedCharacter(char));
        onDone(null);
        return true;
      }

      input.listen(parse);
      return false;
    }

    parse();
  }
}
