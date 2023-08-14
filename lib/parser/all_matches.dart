import '../parser_combinator.dart';
import '../runtime.dart';

class AllMatches
    extends Parser<StringReader, List<({int start, int end, String value})>> {
  final Parser<StringReader, String> p;

  const AllMatches(this.p, {String? name}) : super(name);

  @override
  Parser<StringReader, List<({int start, int end, String value})>> build(
      ParserBuilder<StringReader> builder) {
    return AllMatches(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    final length = input.length;
    if (state.pos >= length) {
      return true;
    }

    while (state.pos < length) {
      final r = p.fastParse(state);
      if (!r) {
        input.readChar(state.pos);
        state.pos += input.count;
      }
    }

    return true;
  }

  @override
  Result<List<({int start, int end, String value})>>? parse(
      State<StringReader> state) {
    final input = state.input;
    final length = input.length;
    if (state.pos >= length) {
      return Result([]);
    }

    final list = <({int start, int end, String value})>[];
    while (state.pos < length) {
      final start = state.pos;
      final r = p.parse(state);
      if (r == null) {
        input.readChar(state.pos);
        state.pos += input.count;
      } else {
        final v = input.substring(start, state.pos);
        list.add((start: start, end: state.pos, value: v));
      }
    }

    return Result(list);
  }
}
