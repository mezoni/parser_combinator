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
  void parseAsync(State<ChunkedData<I>> state, ResultCallback<Object?> onDone) {
    final pos = state.pos;
    void parse() {
      p.parseAsync(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          state.pos = pos;
          onDone(Result(null));
        }
      });
    }

    parse();
  }
}
