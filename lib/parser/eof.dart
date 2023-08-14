import '../parser_combinator.dart';
import '../runtime.dart';
import '../string_reader.dart';

class Eof extends Parser<StringReader, Object?> {
  const Eof({String? name}) : super(name);

  @override
  Parser<StringReader, Object?> build(ParserBuilder<StringReader> builder) {
    return Eof(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    if (state.pos >= state.input.length) {
      return true;
    }

    state.fail<Object?>(const ErrorExpectedEndOfInput());
    return false;
  }

  @override
  Result<Object?>? parse(State<StringReader> state) {
    if (state.pos >= state.input.length) {
      return const Result(null);
    }

    return state.fail(const ErrorExpectedEndOfInput());
  }
}
