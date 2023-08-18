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
      State<ChunkedData<StringReader>> state, ResultCallback<int> onDone) {
    if (!backtrack(state)) {
      onDone(null);
      return;
    }

    final input = state.input;
    final start = input.start;
    input.buffering++;
    void parse() {
      final data = input.data;
      final end = input.end;
      if (state.pos >= end && !input.isClosed) {
        input.sleep = true;
        input.handle(parse);
        return;
      }

      input.buffering--;
      int? c;
      if (state.pos < end) {
        final source = data.source!;
        c = source.runeAt(state.pos - start);
        if (f(c)) {
          state.pos += c > 0xffff ? 2 : 1;
          onDone(Result(c));
          return;
        }
      }

      state.fail<Object?>(ErrorUnexpectedCharacter(c));
      onDone(null);
    }

    parse();
  }
}
