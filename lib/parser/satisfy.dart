import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Satisfy extends Parser<StringReader, int> {
  final Predicate<int> f;

  const Satisfy(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, int> build(ParserBuilder<StringReader> builder) {
    return Satisfy(name: name, f);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    if (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (f(c)) {
        state.pos += input.count;
        return true;
      }
    }

    state.fail<Object?>(ErrorUnexpectedCharacter());
    return false;
  }

  @override
  Result<int>? parse(State<StringReader> state) {
    final input = state.input;
    if (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (f(c)) {
        state.pos += input.count;
        return Result(c);
      }
    }

    return state.fail(ErrorUnexpectedCharacter());
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, VoidCallback1<int> onDone) {
    final p = _AsyncSatisfyParser(f);
    p.parseAsync(state, onDone);
  }
}

class _AsyncSatisfyParser extends ChunkedDataParser<int> {
  int? c;

  final Predicate<int> f;

  _AsyncSatisfyParser(this.f);

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(ErrorUnexpectedCharacter(c));
  }

  @override
  bool? parseChar(int c) {
    if (f(c)) {
      result = Result(c);
      return true;
    }

    this.c = c;
    return false;
  }
}
