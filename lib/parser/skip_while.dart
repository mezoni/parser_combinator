import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

/// Applies a predicate [f] to each parsed character and consumes input until
/// the predicate returns true.
///
/// Parsing always succeeds.
///
/// Returns: Empty string.
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
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<String>();
    if (!backtrack(state)) {
      result.ok = false;
      return result;
    }

    final input = state.input;
    final start = input.start;
    input.buffering++;

    final data = input.data;
    final source = data.source;
    final end = input.end;
    var ok = true;
    int? c;
    while (state.pos < end) {
      c = source.runeAt(state.pos - start);
      if (!f(c)) {
        ok = false;
        break;
      }

      state.pos += c > 0xffff ? 2 : 1;
    }

    if (!ok) {
      input.buffering--;
      result.value = const Result('');
      result.ok = true;
      input.handler = result.handler;
      return result;
    }

    void parse() {
      final data = input.data;
      final source = data.source;
      final end = input.end;
      var ok = true;
      int? c;
      while (state.pos < end) {
        c = source.runeAt(state.pos - start);
        if (!f(c)) {
          ok = false;
          break;
        }

        state.pos += c > 0xffff ? 2 : 1;
      }

      if (ok && !input.isClosed) {
        input.sleep = true;
        input.handler = parse;
        return;
      }

      input.buffering--;
      result.value = const Result('');
      result.ok = true;
      input.handler = result.handler;
    }

    parse();
    return result;
  }
}
