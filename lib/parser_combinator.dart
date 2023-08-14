import 'runtime.dart';
import 'streaming.dart';

typedef Predicate<T> = bool Function(T);

typedef VoidCallback1<T> = void Function(Result<T>? result);

abstract class Parser<I, O> {
  final String? name;

  const Parser([this.name]);

  Type get getInputType => I;

  Type get getOutputType => O;

  Parser<I, O> build(ParserBuilder<I> builder);

  bool fastParse(State<I> state) {
    final result = parse(state);
    return result != null;
  }

  Result<O>? parse(State<I> state);

  void parseStream(State<ChunkedData<I>> state, VoidCallback1<O> onDone) {
    throw UnimplementedError();
  }

  @override
  String toString() {
    if (name case final String name) {
      return name;
    }

    return '$runtimeType';
  }
}

class ParserBuilder<I> {
  final processed = <Parser<I, Object?>, Parser<I, Object?>>{};

  final Parser<I, O> Function<O>(ParserBuilder<I> builder, Parser<I, O> parser)
      _build;

  ParserBuilder(
      Parser<I, O> Function<O>(ParserBuilder<I> builder, Parser<I, O> parser)
          build)
      : _build = build;

  Parser<I, O> build<O>(Parser<I, O> parser) {
    final found = processed[parser];
    if (found != null) {
      return found as Parser<I, O>;
    }

    final value = _build(this, parser);
    processed[parser] = value;
    return value;
  }
}
