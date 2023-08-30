import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Buffered<I, O> extends Parser<I, O> {
  final Parser<I, O> p;

  const Buffered(this.p, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Buffered(name: name, builder.build(p));
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
    final result = AsyncResult<O>();
    final input = state.input;
    late AsyncResult<O> r1;
    var action = 0;
    input.buffering++;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = p.parseAsync(state);
            action = 1;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 1:
            input.buffering--;
            result.value = r1.value;
            result.ok = r1.ok;
            state.input.handler = result.handler;
            action = -1;
            return;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}
