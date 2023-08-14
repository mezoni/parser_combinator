import '../parser_combinator.dart';
import '../runtime.dart';

class ChainL1<I, O1, O2> extends Parser<I, O1> {
  final O1 Function(O1, O2, O1) f;

  final Parser<I, O1> left;

  final Parser<I, O2> op;

  final Parser<I, O1> right;

  const ChainL1(this.left, this.op, this.right, this.f, {String? name})
      : super(name);

  @override
  Parser<I, O1> build(ParserBuilder<I> builder) {
    return ChainL1(
        name: name,
        builder.build(left),
        builder.build(op),
        builder.build(right),
        f);
  }

  @override
  bool fastParse(State<I> state) {
    final r = parse(state);
    return r != null;
  }

  @override
  Result<O1>? parse(State<I> state) {
    O1? l;
    final r1 = left.parse(state);
    if (r1 != null) {
      l = r1.value;
      while (true) {
        final pos = state.pos;
        final r2 = op.parse(state);
        if (r2 == null) {
          break;
        }

        final r3 = right.parse(state);
        if (r3 == null) {
          state.pos = pos;
          break;
        }

        final o = r2.value;
        final r = r3.value;
        // ignore: null_check_on_nullable_type_parameter
        l = f(l!, o, r);
      }
    }

    if (l != null) {
      return Result(l);
    }

    return null;
  }
}
