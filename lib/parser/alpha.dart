import '../parser_combinator.dart';
import '../runtime.dart';
import '../string_reader.dart';

class Alpha extends Parser<StringReader, String> {
  const Alpha({String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Alpha(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!(c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A)) {
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
      if (!(c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A)) {
        break;
      }

      state.pos += input.count;
    }

    return state.pos != pos
        ? Result(input.substring(pos, state.pos))
        : const Result('');
  }
}
