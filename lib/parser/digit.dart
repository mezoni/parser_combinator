import '../parser_combinator.dart';
import '../runtime.dart';
import '../string_reader.dart';

class Digit extends Parser<StringReader, String> {
  const Digit({String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Digit(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!(c >= 0x30 && c <= 0x39)) {
        break;
      }

      state.pos += input.count;
    }

    return true;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!(c >= 0x30 && c <= 0x39)) {
        break;
      }

      state.pos += input.count;
    }

    return state.pos != pos
        ? Result(input.substring(pos, state.pos))
        : const Result('');
  }
}
