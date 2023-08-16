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
  void parseAsync(
      State<ChunkedData<I>> state, ResultCallback<List<O1>> onDone) {
    final input = state.input;
    final list = <O1>[];
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
          onDone(null);
        } else {
          list.add(result.value);
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}
