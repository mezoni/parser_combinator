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
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<O2> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O2>? r;
    void parse3() {
      end.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index2 = index2;
          onDone(null);
        } else {
          onDone(r);
        }
      });
    }

    void parse2() {
      p.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index2 = index2;
          onDone(null);
        } else {
          r = result;
          input.handle(parse3);
        }
      });
    }

    void parse() {
      this.start.parseStream(state, (result) {
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
