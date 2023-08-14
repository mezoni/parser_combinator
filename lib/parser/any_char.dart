import '../parser_combinator.dart';
import '../runtime.dart';
import '../string_reader.dart';

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
}
