import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Opt<I, O> extends Parser<I, O?> {
  final Parser<I, O> p;

  const Opt(this.p, {String? name}) : super(name);

  @override
  Parser<I, O?> build(ParserBuilder<I> builder) {
    return Opt(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<I> state) {
    p.fastParse(state);
    return true;
  }

  @override
  Result<O?>? parse(State<I> state) {
    final r = p.parse(state);
    if (r != null) {
      return r;
    }

    return const Result(null);
  }

  @override
  AsyncResult<O?> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O?>();
    final r1 = p.parseAsync(state);
    void handle() {
      result.ok = true;
      result.value = r1.ok == true ? r1.value : const Result(null);
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
