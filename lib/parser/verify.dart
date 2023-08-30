import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Verify<I, O> extends Parser<I, O> {
  final Predicate<O> f;

  final ParseError Function(int start, int end, O value) h;

  final Parser<I, O> p;

  const Verify(this.p, this.f, this.h, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Verify(name: name, builder.build(p), f, h);
  }

  @override
  bool fastParse(State<I> state) {
    final r = p.parse(state);
    if (r != null) {
      final v = f(r.value);
      if (v) {
        return true;
      }
    }

    return false;
  }

  @override
  Result<O>? parse(State<I> state) {
    final pos = state.pos;
    final r = p.parse(state);
    if (r == null) {
      return null;
    }

    final v = f(r.value);
    if (v) {
      return Result(r.value);
    }

    final error = h(pos, state.pos, r.value);
    state.pos = pos;
    return state.failAt(pos, error);
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O>();
    final pos = state.pos;
    late AsyncResult<O> r1;
    var action = 0;
    // TODO:
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
            var ok = false;
            if (r1.ok == true) {
              final v1 = r1.value!;
              final v2 = v1.value;
              final v3 = f(v2);
              if (v3) {
                ok = true;
                result.value = v1;
              } else {
                state.pos = pos;
              }
            }

            result.ok = ok;
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
