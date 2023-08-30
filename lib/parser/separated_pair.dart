import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class SeparatedPair<I, O1, O2, O3> extends Parser<I, (O1, O3)> {
  final Parser<I, O1> p1;

  final Parser<I, O3> p2;

  final Parser<I, O2> sep;

  const SeparatedPair(this.p1, this.sep, this.p2, {String? name}) : super(name);

  @override
  Parser<I, (O1, O3)> build(ParserBuilder<I> builder) {
    return SeparatedPair(
        name: name, builder.build(p1), builder.build(sep), builder.build(p2));
  }

  @override
  bool fastParse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = sep.fastParse(state);
      if (r2) {
        final r3 = p2.fastParse(state);
        if (r3) {
          return true;
        }
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<(O1, O3)>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = sep.fastParse(state);
      if (r2) {
        final r3 = p2.parse(state);
        if (r3 != null) {
          return Result((r1.value, r3.value));
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  AsyncResult<(O1, O3)> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<(O1, O3)>();
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
            r1 = p1.parseAsync(state);
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

            r2 = sep.parseAsync(state);
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

            r3 = p2.parseAsync(state);
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
              result.value = Result((
                r1.value!.value,
                r3.value!.value,
              ));
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
