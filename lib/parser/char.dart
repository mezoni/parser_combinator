import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';
import '../string_reader.dart';

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
  void parseStream(
      State<ChunkedData<StringReader>> state, VoidCallback1<int> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final pos = state.pos;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    input.buffering++;
    bool parse() {
      if (input.index0 < input.start) {
        throw UnimplementedError();
      }

      var ok = true;
      while (input.index1 < buffer.length) {
        final chunk = buffer[input.index1];
        if (input.index2 >= chunk.length) {
          input.index0++;
          input.index1++;
          input.index2 = 0;
          continue;
        }

        final c = chunk.readChar(input.index2);
        if (c != char) {
          ok = false;
          break;
        }

        input.index2 += chunk.count;
        state.pos += chunk.count;
        input.buffering--;
        onDone(Result(char));
        return true;
      }

      if (!ok || input.isClosed) {
        input.buffering--;
        input.index0 = index0;
        input.index1 = index1;
        input.index2 = index2;
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
