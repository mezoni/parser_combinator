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
    final p = _AsyncCharParser(char);
    p.parseAsync(state, onDone);
  }
}

class _AsyncCharParser extends ChunkedDataParser<int> {
  final int char;

  _AsyncCharParser(this.char);

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(ErrorExpectedCharacter(char));
  }

  @override
  bool? parseChar(int c) {
    if (c == char) {
      result = Result(c);
      return true;
    }

    return false;
  }
}
