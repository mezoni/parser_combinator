import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Delimited<I, O1, O2, O3> extends Parser<I, O2> {
  final Parser<I, O3> end;

  final Parser<I, O2> p;

  final Parser<I, O1> start;

  const Delimited(this.start, this.p, this.end, {String? name}) : super(name);

  @override
  Parser<I, O2> build(ParserBuilder<I> builder) {
    return Delimited(
        name: name, builder.build(start), builder.build(p), builder.build(end));
  }

  @override
  bool fastParse(State<I> state) {
    final pos = state.pos;
    final r1 = start.fastParse(state);
    if (r1) {
      final r2 = p.fastParse(state);
      if (r2) {
        final r3 = end.fastParse(state);
        if (r3) {
          return true;
        }
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<O2>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = start.fastParse(state);
    if (r1) {
      final r2 = p.parse(state);
      if (r2 != null) {
        final r3 = end.fastParse(state);
        if (r3) {
          return r2;
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseAsync(State<ChunkedData<I>> state, VoidCallback1<O2> onDone) {
    final input = state.input;
    final position = input.position;
    final index = input.index;
    final pos = state.pos;
    Result<O2>? r;
    void parse3() {
      end.parseAsync(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.position = position;
          input.index = index;
          onDone(null);
        } else {
          onDone(r);
        }
      });
    }

    void parse2() {
      p.parseAsync(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.position = position;
          input.index = index;
          onDone(null);
        } else {
          r = result;
          input.handle(parse3);
        }
      });
    }

    void parse() {
      start.parseAsync(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}
