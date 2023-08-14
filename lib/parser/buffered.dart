import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Buffered<I, O> extends Parser<I, O> {
  final Parser<I, O> p;

  const Buffered(this.p, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Buffered(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<I> state) {
    return p.fastParse(state);
  }

  @override
  Result<O>? parse(State<I> state) {
    return p.parse(state);
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<O> onDone) {
    final input = state.input;
    void parse() {
      input.buffering++;
      p.parseStream(state, (result) {
        input.buffering--;
        onDone(result);
      });
    }

    parse();
  }
}
