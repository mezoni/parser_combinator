import 'runtime.dart';
import 'streaming.dart';

typedef Predicate<T> = bool Function(T);

typedef VoidCallback1<T> = void Function(Result<T>? result);

abstract class ChunkedDataParser<O> {
  Result<O>? result;

  void onError(State<ChunkedData<StringReader>> state);

  void parseAsync(
      State<ChunkedData<StringReader>> state, VoidCallback1<O> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final position = input.position;
    final index = input.index;
    final pos = state.pos;
    input.buffering++;
    bool parse() {
      var i = input.position - input.start;
      if (i < 0) {
        input.buffering--;
        input.position = position;
        input.index = index;
        state.failAt<Object?>(state.failPos, ErrorBacktrackingError(state.pos));
        state.pos = pos;
        onDone(null);
        return true;
      }

      int? c;
      var ok = true;
      while (i < buffer.length) {
        final chunk = buffer[i];
        if (input.index >= chunk.length) {
          i++;
          input.position++;
          input.index = 0;
          continue;
        }

        c = chunk.readChar(input.index);
        final r = parseChar(c);
        if (r == false) {
          ok = false;
          break;
        }

        input.index += chunk.count;
        state.pos += chunk.count;
        input.trackCount(state.pos);
        if (r == true) {
          input.buffering--;
          onDone(result!);
          return true;
        }
      }

      if (!ok || input.isClosed) {
        final r = parseError();
        if (r == true) {
          input.buffering--;
          onDone(result!);
          return true;
        } else if (r == null) {
          input.position = position;
          input.index = index;
          state.pos = pos;
          input.listen(parse);
          return false;
        }

        input.buffering--;
        input.position = position;
        input.index = index;
        state.pos = pos;
        onError(state);
        onDone(null);
        return true;
      }

      input.listen(parse);
      return false;
    }

    parse();
  }

  bool? parseChar(int c);

  bool? parseError() {
    return false;
  }
}

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

  void parseAsync(State<ChunkedData<I>> state, VoidCallback1<O> onDone) {
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
