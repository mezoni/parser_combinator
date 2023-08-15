import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class SkipWhile extends Parser<StringReader, String> {
  final Predicate<int> f;

  const SkipWhile(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return SkipWhile(name: name, f);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!f(c)) {
        break;
      }

      state.pos += input.count;
    }

    return true;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final input = state.input;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!f(c)) {
        break;
      }

      state.pos += input.count;
    }

    return const Result('');
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final p = _AsyncSkipWhileParser(f);
    p.parseAsync(state, onDone);
  }
}

class _AsyncSkipWhileParser extends ChunkedDataParser<String> {
  final Predicate<int> f;

  _AsyncSkipWhileParser(this.f);

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(const ErrorUnknownError());
  }

  @override
  bool? parseChar(int c) {
    if (f(c)) {
      return null;
    }

    return false;
  }

  @override
  bool parseError() {
    result = Result('');
    return true;
  }
}
