import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class SeparatedList1<I, O1, O2> extends Parser<I, List<O1>> {
  final Parser<I, O1> p;

  final Parser<I, O2> sep;

  const SeparatedList1(this.p, this.sep, {String? name}) : super(name);

  @override
  Parser<I, List<O1>> build(ParserBuilder<I> builder) {
    return SeparatedList1(name: name, builder.build(p), builder.build(sep));
  }

  @override
  bool fastParse(State<I> state) {
    final r1 = p.fastParse(state);
    if (!r1) {
      return false;
    }

    while (true) {
      final r2 = sep.fastParse(state);
      if (!r2) {
        return true;
      }

      final r3 = p.fastParse(state);
      if (!r3) {
        return false;
      }
    }
  }

  @override
  Result<List<O1>>? parse(State<I> state) {
    final r1 = p.parse(state);
    if (r1 == null) {
      return null;
    }

    final list = [r1.value];
    while (true) {
      final r2 = sep.fastParse(state);
      if (!r2) {
        return Result(list);
      }

      final r3 = p.parse(state);
      if (r3 == null) {
        return null;
      }

      list.add(r3.value);
    }
  }

  @override
  AsyncResult<List<O1>> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<List<O1>>();
    late AsyncResult<O1> r1;
    late AsyncResult<O2> r2;
    final list = <O1>[];
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
            final r = r1.value;
            if (r == null) {
              result.ok = false;
              state.input.handler = result.handler;
              action = -1;
              return;
            }

            list.add(r.value);
            action = 2;
            break;
          case 2:
            r2 = sep.parseAsync(state);
            action = 3;
            if (r2.ok == null) {
              r2.handler = parse;
              return;
            }

            break;
          case 3:
            final r = r2.value;
            if (r == null) {
              result.value = Result(list);
              result.ok = true;
              state.input.handler = result.handler;
              action = -1;
              return;
            }

            action = 4;
            break;
          case 4:
            r1 = p.parseAsync(state);
            action = 5;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 5:
            final r = r1.value;
            if (r == null) {
              result.ok = false;
              state.input.handler = result.handler;
              action = -1;
              return;
            }

            list.add(r.value);
            action = 2;
            break;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}
