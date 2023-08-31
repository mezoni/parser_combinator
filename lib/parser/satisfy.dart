import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

/// Applies a predicate [f] to parsed character and consumes input if the
/// predicate returns true.
///
/// Parsing succeeds if the character has been consumed.
///
/// Otherwise, parsing fails with the error [ErrorUnexpectedCharacter].
///
/// Returns: Consumed character.
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
  AsyncResult<int> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<int>();
    if (!backtrack(state)) {
      result.ok = false;
      return result;
    }

    final input = state.input;
    final start = input.start;
    input.buffering++;

    final data = input.data;
    final end = input.end;
    int? c;
    if (state.pos < end) {
      input.buffering--;
      final source = data.source;
      c = source.runeAt(state.pos - start);
      if (result.ok = f(c)) {
        state.pos += c > 0xffff ? 2 : 1;
        result.value = Result(c);
      } else {
        state.fail<Object?>(ErrorUnexpectedCharacter(c));
      }

      input.handler = result.handler;
      return result;
    }

    void parse() {
      final data = input.data;
      final end = input.end;
      if (state.pos >= end && !input.isClosed) {
        input.sleep = true;
        input.handler = parse;
        return;
      }

      input.buffering--;
      int? c;
      if (state.pos < end) {
        final source = data.source;
        c = source.runeAt(state.pos - start);
        if (f(c)) {
          state.pos += c > 0xffff ? 2 : 1;
          result.value = Result(c);
          result.ok = true;
          input.handler = result.handler;
          return;
        }
      }

      result.ok = false;
      state.fail<Object?>(ErrorUnexpectedCharacter(c));
      input.handler = result.handler;
    }

    parse();
    return result;
  }
}
