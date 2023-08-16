import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Opt<I, O> extends Parser<I, O?> {
  final Parser<I, O> p;

  const Opt(this.p, {String? name}) : super(name);

  @override
  Parser<I, O?> build(ParserBuilder<I> builder) {
    return Opt(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<I> state) {
    p.fastParse(state);
    return true;
  }

  @override
  Result<O?>? parse(State<I> state) {
    final r = p.parse(state);
    if (r != null) {
      return r;
    }

    return const Result(null);
  }

  @override
  void parseAsync(State<ChunkedData<I>> state, ResultCallback<O?> onDone) {
    void parse() {
      p.parseAsync(state, (result) {
        if (result == null) {
          onDone(Result(null));
        } else {
          onDone(result);
        }
      });
    }

    parse();
  }
}
