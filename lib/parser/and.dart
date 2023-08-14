import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class And<I, O1> extends Parser<I, Object?> {
  final Parser<I, O1> p;

  const And(this.p, {String? name}) : super(name);

  @override
  Parser<I, Object?> build(ParserBuilder<I> builder) {
    return And(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<I> state) {
    final pos = state.pos;
    final r = p.fastParse(state);
    if (r) {
      state.pos = pos;
      return true;
    }

    return false;
  }

  @override
  Result<Object?>? parse(State<I> state) {
    final pos = state.pos;
    final r = p.parse(state);
    if (r != null) {
      state.pos = pos;
      return const Result(null);
    }

    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<Object?> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final pos = state.pos;
    void parse() {
      p.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          onDone(Result(null));
        }
      });
    }

    parse();
  }
}
