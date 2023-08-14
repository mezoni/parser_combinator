import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Value<I, O> extends Parser<I, O> {
  final O value;

  const Value(this.value, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Value(name: name, value);
  }

  @override
  bool fastParse(State<I> state) {
    return true;
  }

  @override
  Result<O>? parse(State<I> state) {
    return Result(value);
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<O> onDone) {
    onDone(Result(value));
  }
}

class ValueP<I, O1, O2> extends Parser<I, O2> {
  final Parser<I, O1> p;

  final O2 value;

  const ValueP(this.value, this.p, {String? name}) : super(name);

  @override
  Parser<I, O2> build(ParserBuilder<I> builder) {
    return ValueP(name: name, value, builder.build(p));
  }

  @override
  bool fastParse(State<I> state) {
    return p.fastParse(state);
  }

  @override
  Result<O2>? parse(State<I> state) {
    final r = p.fastParse(state);
    if (r) {
      return Result(value);
    }

    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<O2> onDone) {
    void parse() {
      p.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          onDone(Result(value));
        }
      });
    }

    parse();
  }
}
