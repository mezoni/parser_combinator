import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Preceded<I, O1, O2> extends Parser<I, O2> {
  final Parser<I, O2> p;

  final Parser<I, O1> start;

  const Preceded(this.start, this.p, {String? name}) : super(name);

  @override
  Parser<I, O2> build(ParserBuilder<I> builder) {
    return Preceded(name: name, builder.build(start), builder.build(p));
  }

  @override
  bool fastParse(State<I> state) {
    final pos = state.pos;
    final r1 = start.fastParse(state);
    if (r1) {
      final r2 = p.fastParse(state);
      if (r2) {
        return true;
      }

      state.pos = pos;
    }

    return false;
  }

  @override
  Result<O2>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = start.fastParse(state);
    if (r1) {
      final r2 = p.parse(state);
      if (r2 != null) {
        return r2;
      }

      state.pos = pos;
    }

    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<O2> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    void parse2() {
      p.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          onDone(result);
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