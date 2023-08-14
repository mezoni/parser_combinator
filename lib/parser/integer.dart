import '../parser_combinator.dart';
import '../runtime.dart';

class Integer extends Parser<StringReader, String> {
  const Integer({String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Integer(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final pos = state.pos;
    final input = state.input;
    final length = input.length;
    var ok = false;
    int readChar() {
      if (state.pos < length) {
        return input.readChar(state.pos);
      }

      return -1;
    }

    while (true) {
      var c = readChar();
      if (c == 0x2d) {
        state.pos += input.count;
        c = readChar();
      }

      if (c == 0x30) {
        state.pos += input.count;
        ok = true;
        break;
      }

      if (!(c >= 0x31 && c <= 0x39)) {
        break;
      }

      ok = true;
      state.pos += input.count;
      while (true) {
        c = readChar();
        if (!(c >= 0x30 && c <= 0x39)) {
          break;
        }

        state.pos += input.count;
      }

      break;
    }

    if (!ok) {
      state.pos = pos;
      state.fail<Object?>(const ErrorUnexpectedCharacter());
    }

    return ok;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final pos = state.pos;
    final ok = fastParse(state);
    return ok
        ? Result(state.input.substring(pos, state.pos))
        : state.fail(const ErrorUnexpectedCharacter());
  }
}
