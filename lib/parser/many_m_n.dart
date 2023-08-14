import '../parser_combinator.dart';
import '../runtime.dart';

class ManyMN<I, O> extends Parser<I, List<O>> {
  final int m;

  final int n;

  final Parser<I, O> p;

  const ManyMN(this.m, this.n, this.p, {String? name}) : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return ManyMN(name: name, m, n, builder.build(p));
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
      final r2 = p.parse(state);
      if (r2 == null) {
        break;
      }

      list.add(r2.value);
    }

    if (list.length >= m) {
      return true;
    }

    return false;
  }

  @override
  Result<List<O>>? parse(State<I> state) {
    if (m > n) {
      throw RangeError.range(m, 0, n, 'm');
    }

    final r1 = p.parse(state);
    if (r1 == null) {
      return m == 0 ? Result([]) : null;
    }

    final list = [r1.value];
    while (list.length < n) {
      final r2 = p.parse(state);
      if (r2 == null) {
        break;
      }

      list.add(r2.value);
    }

    if (list.length >= m) {
      return Result(list);
    }

    return null;
  }
}
