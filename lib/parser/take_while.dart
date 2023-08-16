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
  void parseAsync(
      State<ChunkedData<StringReader>> state, ResultCallback<String> onDone) {
    if (!backtrack(state)) {
      onDone(null);
      return;
    }

    final input = state.input;
    final charCodes = <int>[];
    input.buffering++;
    bool parse() {
      final data = input.data;
      final start = input.start;
      final end = start + data.length;
      while (state.pos < end) {
        final c = data.readChar(state.pos - start);
        if (!f(c)) {
          break;
        }

        state.pos += data.count;
        charCodes.add(c);
      }

      if (!input.isClosed) {
        input.listen(parse);
        return false;
      }

      input.buffering--;
      final result = charCodes.isNotEmpty
          ? Result(String.fromCharCodes(charCodes))
          : const Result('');
      onDone(result);
      return true;
    }

    parse();
  }
}
