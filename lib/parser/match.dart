import '../parser_combinator.dart';
import '../runtime.dart';
import '../string_reader.dart';

class Match1<O>
    extends Parser<StringReader, ({int start, int end, String value})> {
  final Parser<StringReader, O> p;

  const Match1(this.p, {String? name}) : super(name);

  @override
  Parser<StringReader, ({int start, int end, String value})> build(
      ParserBuilder<StringReader> builder) {
    return Match1(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<StringReader> state) {
    return p.fastParse(state);
  }

  @override
  Result<({int start, int end, String value})>? parse(
      State<StringReader> state) {
    final pos = state.pos;
    final r = p.parse(state);
    if (r != null) {
      final v = state.input.substring(pos, state.pos);
      return Result((start: pos, end: state.pos, value: v));
    }

    return null;
  }
}
