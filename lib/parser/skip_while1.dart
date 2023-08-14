import '../parser_combinator.dart';
import '../runtime.dart';
import '../string_reader.dart';

class SkipWhile1 extends Parser<StringReader, String> {
  final Predicate<int> f;

  const SkipWhile1(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return SkipWhile1(name: name, f);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!f(c)) {
        break;
      }

      state.pos += input.count;
    }

    if (state.pos != pos) {
      return true;
    }

    state.fail<Object?>(const ErrorUnexpectedCharacter());
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!f(c)) {
        break;
      }

      state.pos += input.count;
    }

    return state.pos != pos
        ? const Result('')
        : state.fail(const ErrorUnexpectedCharacter());
  }
}
