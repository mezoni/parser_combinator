import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Many<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p;

  const Many(this.p, {String? name}) : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return Many(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<I> state) {
    final r = p.fastParse(state);
    if (!r) {
      return true;
    }

    while (true) {
      final r = p.parse(state);
      if (r == null) {
        break;
      }
    }

    return true;
  }

  @override
  Result<List<O>>? parse(State<I> state) {
    final r = p.parse(state);
    if (r == null) {
      return Result([]);
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
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<List<O>> onDone) {
    final input = state.input;
    final list = <O>[];
    void parse() {
      p.parseStream(state, (result) {
        if (result == null) {
          onDone(Result(list));
        } else {
          list.add(result.value);
          input.handle(parse);
        }
      });
    }

    parse();
  }
}
