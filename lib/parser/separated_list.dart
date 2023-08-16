import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class SeparatedList<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p;

  final Parser<I, Object?> sep;

  const SeparatedList(this.p, this.sep, {String? name}) : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return SeparatedList(name: name, builder.build(p), builder.build(sep));
  }

  @override
  bool fastParse(State<I> state) {
    final r1 = p.fastParse(state);
    if (!r1) {
      return true;
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
  Result<List<O>>? parse(State<I> state) {
    final r1 = p.parse(state);
    if (r1 == null) {
      return const Result([]);
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
  void parseAsync(State<ChunkedData<I>> state, ResultCallback<List<O>> onDone) {
    final input = state.input;
    final list = <O>[];
    void parse2() {
      void parse3() {
        p.parseAsync(state, (result) {
          if (result == null) {
            onDone(null);
          } else {
            list.add(result.value);
            input.handle(parse2);
          }
        });
      }

      sep.parseAsync(state, (result) {
        if (result == null) {
          onDone(Result(list));
        } else {
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p.parseAsync(state, (result) {
        if (result == null) {
          onDone(const Result([]));
        } else {
          list.add(result.value);
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}
