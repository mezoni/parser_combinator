import '../parser_combinator.dart';
import '../runtime.dart';

class SeparatedListMN<I, O1, O2> extends Parser<I, List<O1>> {
  final int m;

  final int n;

  final Parser<I, O1> p;

  final Parser<I, O2> sep;

  const SeparatedListMN(this.m, this.n, this.p, this.sep, {String? name})
      : super(name);

  @override
  Parser<I, List<O1>> build(ParserBuilder<I> builder) {
    return SeparatedListMN(
        name: name, m, n, builder.build(p), builder.build(sep));
  }

  @override
  bool fastParse(State<I> state) {
    if (m > n) {
      throw RangeError.range(m, 0, n, 'm');
    }

    final r1 = p.parse(state);
    if (r1 == null) {
      return m == 0;
    }

    final list = [r1.value];
    while (list.length < n) {
      final r2 = sep.fastParse(state);
      if (!r2) {
        break;
      }

      final r3 = p.parse(state);
      if (r3 == null) {
        return false;
      }

      list.add(r3.value);
    }

    if (list.length >= m) {
      return true;
    }

    return false;
  }

  @override
  Result<List<O1>>? parse(State<I> state) {
    if (m > n) {
      throw RangeError.range(m, 0, n, 'm');
    }

    final r1 = p.parse(state);
    if (r1 == null) {
      return m == 0 ? Result([]) : null;
    }

    final list = [r1.value];
    while (list.length < n) {
      final r2 = sep.fastParse(state);
      if (!r2) {
        break;
      }

      final r3 = p.parse(state);
      if (r3 == null) {
        return null;
      }

      list.add(r3.value);
    }

    if (list.length >= m) {
      return Result(list);
    }

    return null;
  }
}
