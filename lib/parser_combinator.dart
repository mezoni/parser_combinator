import 'runtime.dart';
import 'streaming.dart';

typedef Predicate<T> = bool Function(T);

typedef ResultCallback<T> = void Function(Result<T>? result);

typedef VoidCallback1<T> = void Function(T result);

abstract class Parser<I, O> {
  final String? name;

  const Parser([this.name]);

  Type get getInputType => I;

  Type get getOutputType => O;

  bool backtrack(State<ChunkedData<I>> state) {
    final input = state.input;
    if (state.pos < input.start) {
      state.failAt<Object?>(state.failPos, ErrorBacktrackingError(state.pos));
      return false;
    }

    return true;
  }

  Parser<I, O> build(ParserBuilder<I> builder);

  bool fastParse(State<I> state) {
    final result = parse(state);
    return result != null;
  }

  Result<O>? parse(State<I> state);

  void parseAsync(State<ChunkedData<I>> state, ResultCallback<O> onDone) {
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
