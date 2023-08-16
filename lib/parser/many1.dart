import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

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
  void parseAsync(State<ChunkedData<I>> state, ResultCallback<List<O>> onDone) {
    final input = state.input;
    final list = <O>[];
    void parse() {
      p.parseAsync(state, (result) {
        if (result == null) {
          final result = list.isNotEmpty ? Result(list) : null;
          onDone(result);
        } else {
          list.add(result.value);
          input.handle(parse);
        }
      });
    }

    parse();
  }
}
