import '../parser_combinator.dart';
import '../runtime.dart';
import '../string_reader.dart';

class TakeWhile extends Parser<StringReader, String> {
  final Predicate<int> f;

  const TakeWhile(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return TakeWhile(name: name, f);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!f(c)) {
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
      if (!f(c)) {
        break;
      }

      state.pos += input.count;
    }

    return state.pos != pos
        ? Result(input.substring(pos, state.pos))
        : const Result('');
  }
}
