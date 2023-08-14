import '../parser_combinator.dart';
import '../runtime.dart';

class Rest extends Parser<StringReader, String> {
  const Rest({String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Rest(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    return true;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final input = state.input;
    if (state.pos < input.length) {
      return Result(input.substring(state.pos, input.length));
    }

    return const Result('');
  }
}
