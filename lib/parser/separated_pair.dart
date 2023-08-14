import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class SeparatedPair<I, O1, O2, O3> extends Parser<I, (O1, O3)> {
  final Parser<I, O1> p1;

  final Parser<I, O3> p2;

  final Parser<I, O2> sep;

  const SeparatedPair(this.p1, this.sep, this.p2, {String? name}) : super(name);

  @override
  Parser<I, (O1, O3)> build(ParserBuilder<I> builder) {
    return SeparatedPair(
        name: name, builder.build(p1), builder.build(sep), builder.build(p2));
  }

  @override
  bool fastParse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = sep.fastParse(state);
      if (r2) {
        final r3 = p2.fastParse(state);
        if (r3) {
          return true;
        }
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<(O1, O3)>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = sep.fastParse(state);
      if (r2) {
        final r3 = p2.parse(state);
        if (r3 != null) {
          return Result((r1.value, r3.value));
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseAsync(State<ChunkedData<I>> state, VoidCallback1<(O1, O3)> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final pos = state.pos;
    Result<O1>? r1;
    Result<O3>? r3;
    void parse3() {
      p2.parseAsync(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          onDone(null);
        } else {
          r3 = result;
          onDone(Result((r1!.value, r3!.value)));
        }
      });
    }

    void parse2() {
      sep.parseAsync(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          onDone(null);
        } else {
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseAsync(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          r1 = result;
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}
