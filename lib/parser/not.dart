import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Not<I, O1> extends Parser<I, Object?> {
  final Parser<I, O1> p;

  const Not(this.p, {String? name}) : super(name);

  @override
  Parser<I, Object?> build(ParserBuilder<I> builder) {
    return Not(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<I> state) {
    final pos = state.pos;
    final r = p.fastParse(state);
    if (!r) {
      return true;
    }

    state.pos = pos;
    state.fail<Object?>(ErrorUnexpectedInput(pos - state.pos));
    return false;
  }

  @override
  Result<Object?>? parse(State<I> state) {
    final pos = state.pos;
    final r = p.parse(state);
    if (r == null) {
      return const Result(null);
    }

    state.pos = pos;
    return state.fail(ErrorUnexpectedInput(pos - state.pos));
  }

  @override
  void parseAsync(State<ChunkedData<I>> state, VoidCallback1<Object?> onDone) {
    final input = state.input;
    final position = input.position;
    final index = input.index;
    final pos = state.pos;
    void parse() {
      p.parseAsync(state, (result) {
        if (result == null) {
          onDone(Result(null));
        } else {
          state.pos = pos;
          input.position = position;
          input.index = index;
          state.fail<Object?>(ErrorUnexpectedInput(pos - state.pos));
          onDone(null);
        }
      });
    }

    parse();
  }
}
