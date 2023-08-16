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
    final charCodes = <int>[];
    input.buffering++;
    bool parse() {
      final data = input.data;
      final start = input.start;
      final end = start + data.length;
      int? c;
      while (state.pos < end) {
        c = data.readChar(state.pos - start);
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
      if (charCodes.isEmpty) {
        state.fail<Object?>(ErrorUnexpectedCharacter(c));
        onDone(null);
      } else {
        onDone(Result(String.fromCharCodes(charCodes)));
      }

      return true;
    }

    parse();
  }
}
