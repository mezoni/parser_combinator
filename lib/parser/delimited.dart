import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Delimited<I, O1, O2, O3> extends Parser<I, O2> {
  final Parser<I, O3> end;

  final Parser<I, O2> p;

  final Parser<I, O1> start;

  const Delimited(this.start, this.p, this.end, {String? name}) : super(name);

  @override
  Parser<I, O2> build(ParserBuilder<I> builder) {
    return Delimited(
        name: name, builder.build(start), builder.build(p), builder.build(end));
  }

  @override
  bool fastParse(State<I> state) {
    final pos = state.pos;
    final r1 = start.fastParse(state);
    if (r1) {
      final r2 = p.fastParse(state);
      if (r2) {
        final r3 = end.fastParse(state);
        if (r3) {
          return true;
        }
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<O2>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = start.fastParse(state);
    if (r1) {
      final r2 = p.parse(state);
      if (r2 != null) {
        final r3 = end.fastParse(state);
        if (r3) {
          return r2;
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  AsyncResult<O2> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O2>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O1> r1;
    late AsyncResult<O2> r2;
    late AsyncResult<O3> r3;
    var action = 0;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = start.parseAsync(state);
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

            r2 = p.parseAsync(state);
            action = 2;
            if (r2.ok == null) {
              r2.handler = parse;
              return;
            }

            break;
          case 2:
            if (r2.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r3 = end.parseAsync(state);
            action = 3;
            if (r3.ok == null) {
              r3.handler = parse;
              return;
            }

            break;
          case 3:
            if ((result.ok = r3.ok) == false) {
              state.pos = pos;
            } else {
              result.value = r2.value;
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
