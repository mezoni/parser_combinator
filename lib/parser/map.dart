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
  AsyncResult<O2> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O2>();
    late AsyncResult<O1> r1;
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
            if ((result.ok = r1.ok) == true) {
              final v1 = r1.value!.value;
              final v2 = f(v1);
              result.value = Result(v2);
            }

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
