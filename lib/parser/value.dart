import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Value<I, O> extends Parser<I, O> {
  final O value;

  const Value(this.value, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Value(name: name, value);
  }

  @override
  bool fastParse(State<I> state) {
    return true;
  }

  @override
  Result<O>? parse(State<I> state) {
    return Result(value);
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O>();
    result.value = Result(value);
    result.ok = true;
    return result;
  }
}

class ValueP<I, O1, O2> extends Parser<I, O2> {
  final Parser<I, O1> p;

  final O2 value;

  const ValueP(this.value, this.p, {String? name}) : super(name);

  @override
  Parser<I, O2> build(ParserBuilder<I> builder) {
    return ValueP(name: name, value, builder.build(p));
  }

  @override
  bool fastParse(State<I> state) {
    return p.fastParse(state);
  }

  @override
  Result<O2>? parse(State<I> state) {
    final r = p.fastParse(state);
    if (r) {
      return Result(value);
    }

    return null;
  }

  @override
  AsyncResult<O2> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O2>();
    final r1 = p.parseAsync(state);
    void handle() {
      if ((result.ok = r1.ok) == true) {
        result.value = Result(value);
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
