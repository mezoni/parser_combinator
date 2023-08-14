import '../parser_combinator.dart';
import '../runtime.dart';

class OneOf extends Parser<StringReader, int> {
  final String chars;

  const OneOf(this.chars, {String? name}) : super(name);

  @override
  Parser<StringReader, int> build(ParserBuilder<StringReader> builder) {
    return OneOf(name: name, chars);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    if (pos < input.length) {
      final c = input.readChar(state.pos);
      for (var i = 0; i < chars.length; i++) {
        if (chars.codeUnitAt(i) == c) {
          state.pos += input.count;
          return true;
        }
      }
    }

    state.fail<Object?>(ErrorUnexpectedCharacter());
    return false;
  }

  @override
  Result<int>? parse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    if (pos < input.length) {
      final c = input.readChar(state.pos);
      for (var i = 0; i < chars.length; i++) {
        if (chars.codeUnitAt(i) == c) {
          state.pos += input.count;
          return Result(c);
        }
      }
    }

    return state.fail(ErrorUnexpectedCharacter());
  }
}
