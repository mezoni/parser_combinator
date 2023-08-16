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
  void parseAsync(State<ChunkedData<I>> state, ResultCallback<O1> onDone) {
    final input = state.input;
    final pos = state.pos;
    Result<O1>? r1;
    void parse2() {
      end.parseAsync(state, (result) {
        if (result == null) {
          state.pos = pos;
          onDone(null);
        } else {
          onDone(r1);
        }
      });
    }

    void parse() {
      p.parseAsync(state, (result) {
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
