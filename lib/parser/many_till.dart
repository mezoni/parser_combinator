import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class ManyTill<I, O1, O2> extends Parser<I, (List<O1>, O2)> {
  final Parser<I, O2> end;

  final Parser<I, O1> p;

  const ManyTill(this.p, this.end, {String? name}) : super(name);

  @override
  Parser<I, (List<O1>, O2)> build(ParserBuilder<I> builder) {
    return ManyTill(name: name, builder.build(p), builder.build(end));
  }

  @override
  bool fastParse(State<I> state) {
    final r1 = end.fastParse(state);
    if (r1) {
      return true;
    }

    final pos = state.pos;
    final r2 = p.fastParse(state);
    if (!r2) {
      return false;
    }

    while (true) {
      final r1 = end.fastParse(state);
      if (r1) {
        return true;
      }

      final r2 = p.fastParse(state);
      if (!r2) {
        state.pos = pos;
        return false;
      }
    }
  }

  @override
  Result<(List<O1>, O2)>? parse(State<I> state) {
    final r1 = end.parse(state);
    if (r1 != null) {
      return Result(([], r1.value));
    }

    final pos = state.pos;
    final r2 = p.parse(state);
    if (r2 == null) {
      return null;
    }

    final list = [r2.value];
    while (true) {
      final r1 = end.parse(state);
      if (r1 != null) {
        return Result((list, r1.value));
      }

      final r2 = p.parse(state);
      if (r2 == null) {
        state.pos = pos;
        return null;
      }

      list.add(r2.value);
    }
  }
}
