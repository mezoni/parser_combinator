import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class TakeWhile extends Parser<StringReader, String> {
  final Predicate<int> f;

  const TakeWhile(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return TakeWhile(name: name, f);
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
    final pos = state.pos;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!f(c)) {
        break;
      }

      state.pos += input.count;
    }

    return state.pos != pos
        ? Result(input.substring(pos, state.pos))
        : const Result('');
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
    final pos = state.pos;
    input.buffering++;

    final data = input.data;
    final source = data.source!;
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
      result.value = state.pos != pos
          ? Result(source.substring(pos - start, state.pos - start))
          : const Result('');
      result.ok = true;
      input.handler = result.handler;
      return result;
    }

    void parse() {
      final data = input.data;
      final source = data.source!;
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
      result.value = state.pos != pos
          ? Result(source.substring(pos - start, state.pos - start))
          : const Result('');
      result.ok = true;
      input.handler = result.handler;
    }

    parse();
    return result;
  }
}
