import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

/// Cyclically invokes the [p] parser and stores each parse result in a list
/// until the [p] parser fails.
///
/// Parsing succeeds if at least one result of loop parsing by the [p] parser is
/// available.
///
/// Otherwise, parsing fails.
///
/// Returns: List of parsing results.
class Many1<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p;

  const Many1(this.p, {String? name}) : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return Many1(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<I> state) {
    final r = p.fastParse(state);
    if (!r) {
      return false;
    }

    while (true) {
      final r = p.fastParse(state);
      if (!r) {
        return true;
      }
    }
  }

  @override
  Result<List<O>>? parse(State<I> state) {
    final r = p.parse(state);
    if (r == null) {
      return null;
    }

    final list = [r.value];
    while (true) {
      final r = p.parse(state);
      if (r == null) {
        return Result(list);
      }

      list.add(r.value);
    }
  }

  @override
  AsyncResult<List<O>> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<List<O>>();
    late AsyncResult<O> r1;
    final list = <O>[];
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
              if (result.ok = list.isNotEmpty) {
                result.value = Result(list);
              }

              state.input.handler = result.handler;
              action = -1;
              return;
            }

            list.add(r.value);
            action = 0;
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
