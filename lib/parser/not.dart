import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Not<I, O> extends Parser<I, Object?> {
  final Parser<I, O> p;

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
  AsyncResult<Object?> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<Object?>();
    final pos = state.pos;
    final r1 = p.parseAsync(state);
    void handle() {
      result.ok = r1.ok != true;
      if (result.ok == false) {
        state.pos = pos;
        state.fail<Object?>(ErrorUnexpectedInput(pos - state.pos));
      } else {
        result.value = const Result<Object?>(null);
      }

      state.input.handler = result.handler;
    }

    if (r1.ok != null) {
      handle();
    } else {
      r1.handler = handle;
    }

    return result;
  }
}
