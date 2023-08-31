import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

/// Stores the current parsing position, invokes the [p] parser and then
/// restores the current parse position.
///
/// Parsing succeeds if parsing by the [p] parser succeeds.
///
/// Otherwise, parsing fails.
///
/// Returns: Value with type [Object]?.
class And<I, O> extends Parser<I, Object?> {
  final Parser<I, O> p;

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
  AsyncResult<Object?> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<Object?>();
    final pos = state.pos;
    final r1 = p.parseAsync(state);
    void handle() {
      if ((result.ok = r1.ok) == true) {
        state.pos = pos;
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
