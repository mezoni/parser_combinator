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
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<O> onDone) {
    final pos = state.pos;
    void parse() {
      p.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          final value = result.value;
          final v = f(value);
          if (v) {
            onDone(Result(value));
          } else {
            final error = h(pos, state.pos, value);
            state.pos = pos;
            state.failAt<Object?>(pos, error);
            onDone(null);
          }
        }
      });
    }

    parse();
  }
}
