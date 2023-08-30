import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Calc<I, O> extends Parser<I, O> {
  final O Function() f;

  const Calc(this.f, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Calc(name: name, f);
  }

  @override
  bool fastParse(State<I> state) {
    f();
    return true;
  }

  @override
  Result<O>? parse(State<I> state) {
    final v = f();
    return Result(v);
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final v = f();
    final result = AsyncResult<O>();
    result.value = Result(v);
    result.ok = true;
    return result;
  }
}
