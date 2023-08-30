import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Terminated<I, O1, O2> extends Parser<I, O1> {
  final Parser<I, O2> end;

  final Parser<I, O1> p;

  const Terminated(this.p, this.end, {String? name}) : super(name);

  @override
  Parser<I, O1> build(ParserBuilder<I> builder) {
    return Terminated(name: name, builder.build(p), builder.build(end));
  }

  @override
  bool fastParse(State<I> state) {
    final pos = state.pos;
    final r1 = p.fastParse(state);
    if (r1) {
      final r2 = end.fastParse(state);
      if (r2) {
        return true;
      }

      state.pos = pos;
    }

    return false;
  }

  @override
  Result<O1>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p.parse(state);
    if (r1 != null) {
      final r2 = end.fastParse(state);
      if (r2) {
        return r1;
      }

      state.pos = pos;
    }

    return null;
  }

  @override
  AsyncResult<O1> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O1>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O1> r1;
    late AsyncResult<O2> r2;
    var action = 0;
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
            if (r1.ok == false) {
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r2 = end.parseAsync(state);
            action = 2;
            if (r2.ok == null) {
              r2.handler = parse;
              return;
            }

            break;
          case 2:
            if ((result.ok = r2.ok) == false) {
              state.pos = pos;
            } else {
              result.value = r1.value;
            }

            input.handler = result.handler;
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
