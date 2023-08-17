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
      State<ChunkedData<StringReader>> state, ResultCallback<String> onDone) {
    if (!backtrack(state)) {
      onDone(null);
      return;
    }

    final input = state.input;
    input.buffering++;
    void parse() {
      final data = input.data;
      final source = data.source!;
      while (true) {
        if (input.isIncomplete(state.pos)) {
          input.sleep = true;
          input.handle(parse);
          return;
        }

        if (!input.isEnd(state.pos)) {
          final c = source.runeAt(state.pos - input.start);
          if (f(c)) {
            state.pos += c > 0xffff ? 2 : 1;
            continue;
          }
        }

        input.buffering--;
        onDone(const Result(''));
        return;
      }
    }

    parse();
  }
}
