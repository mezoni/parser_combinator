import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Wrapper<I, O> extends Parser<I, O> {
  final Parser<I, O> p;

  const Wrapper(this.p, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Wrapper(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<I> state) {
    return p.fastParse(state);
  }

  @override
  Result<O>? parse(State<I> state) {
    return p.parse(state);
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    return p.parseAsync(state);
  }
}
