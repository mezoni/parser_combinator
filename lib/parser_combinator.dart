import 'runtime.dart';
import 'streaming.dart';

typedef Predicate<T> = bool Function(T);

typedef VoidCallback1<T> = void Function(T result);

class AsyncResult<T> {
  bool? ok;

  Result<T>? value;

  void Function()? _handler;

  void Function()? get handler => _handler;

  set handler(void Function()? handler) {
    if (handler == null) {
      _handler = null;
    } else {
      if (_handler == null) {
        _handler = handler;
      } else {
        final f = _handler;
        _handler = () {
          handler();
          if (f != null) {
            f();
          }
        };
      }
    }
  }
}

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

  /// Builds a new parser using the specified [builder].
  Parser<I, O> build(ParserBuilder<I> builder);

  /// Parses the input and returns `true` if successful, `false` otherwise.
  bool fastParse(State<I> state) {
    final result = parse(state);
    return result != null;
  }

  /// Parses the input and returns a result wrapped in [Result] if successful,
  /// `null` otherwise.
  Result<O>? parse(State<I> state);

  /// Experimental. Not yet fully implemented
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
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
