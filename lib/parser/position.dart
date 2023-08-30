import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Position<I> extends Parser<I, int> {
  const Position({String? name}) : super(name);

  @override
  Parser<I, int> build(ParserBuilder<I> builder) {
    return Position(name: name);
  }

  @override
  bool fastParse(State<I> state) {
    return true;
  }

  @override
  Result<int>? parse(State<I> state) {
    return Result(state.pos);
  }

  @override
  AsyncResult<int> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<int>();
    result.value = Result(state.pos);
    result.ok = true;
    return result;
  }
}
