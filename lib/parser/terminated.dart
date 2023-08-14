import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Terminated<I, O1, O2> extends Parser<I, O1> {
  final Parser<I, O2> end;

  final Parser<I, O1> p;

  const Terminated(this.p, this.end, {String? name}) : super(name);

  @override
  Parser<I, O1> build(ParserBuilder<I> builder) {
    return Terminated(name: name, builder.build(p), builder.build(end));
  }

  @override
  bool fastParse(State<I> state) {
    final pos = state.pos;
    final r1 = p.fastParse(state);
    if (r1) {
      final r2 = end.fastParse(state);
      if (r2) {
        return true;
      }

      state.pos = pos;
    }

    return false;
  }

  @override
  Result<O1>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p.parse(state);
    if (r1 != null) {
      final r2 = end.fastParse(state);
      if (r2) {
        return r1;
      }

      state.pos = pos;
    }

    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<O1> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O1>? r1;
    void parse2() {
      end.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          onDone(r1);
        }
      });
    }

    void parse() {
      p.parseStream(state, (result) {
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
