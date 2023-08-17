import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class TakeWhile1 extends Parser<StringReader, String> {
  final Predicate<int> f;

  const TakeWhile1(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return TakeWhile1(name: name, f);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!f(c)) {
        break;
      }

      state.pos += input.count;
    }

    if (state.pos != pos) {
      return true;
    }

    state.fail<Object?>(const ErrorUnexpectedCharacter());
    return false;
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
        : state.fail(const ErrorUnexpectedCharacter());
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, ResultCallback<String> onDone) {
    if (!backtrack(state)) {
      onDone(null);
      return;
    }

    final input = state.input;
    final start = input.start;
    final pos = state.pos;
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

        int? c;
        if (!input.isEnd(state.pos)) {
          c = source.runeAt(state.pos - start);
          if (f(c)) {
            state.pos += c > 0xffff ? 2 : 1;
            continue;
          }
        }

        input.buffering--;
        if (state.pos != pos) {
          onDone(Result(source.substring(pos - start, state.pos - start)));
        } else {
          state.fail<Object?>(ErrorUnexpectedCharacter(c));
          state.pos = pos;
          onDone(null);
        }

        return;
      }
    }

    parse();
  }
}
