import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Map1<I, O1, O2> extends Parser<I, O2> {
  final O2 Function(O1) f;

  final Parser<I, O1> p;

  const Map1(this.p, this.f, {String? name}) : super(name);

  @override
  Parser<I, O2> build(ParserBuilder<I> builder) {
    return Map1(name: name, builder.build(p), f);
  }

  @override
  bool fastParse(State<I> state) {
    final r = p.parse(state);
    if (r != null) {
      // ignore: unused_local_variable
      final v = f(r.value);
      return true;
    }

    return false;
  }

  @override
  Result<O2>? parse(State<I> state) {
    final r = p.parse(state);
    if (r != null) {
      final v = f(r.value);
      return Result(v);
    }

    return null;
  }

  @override
  void parseAsync(State<ChunkedData<I>> state, ResultCallback<O2> onDone) {
    void parse() {
      p.parseAsync(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          final v = f(result.value);
          onDone(Result(v));
        }
      });
    }

    parse();
  }
}
