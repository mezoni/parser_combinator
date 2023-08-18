import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Digit1 extends Parser<StringReader, String> {
  const Digit1({String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Digit1(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!(c >= 0x30 && c <= 0x39)) {
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
      if (!(c >= 0x30 && c <= 0x39)) {
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
      final end = input.end;
      var ok = true;
      int? c;
      while (state.pos < end) {
        c = source.runeAt(state.pos - start);
        if (!(c >= 0x30 && c <= 0x39)) {
          ok = false;
          break;
        }

        state.pos++;
      }

      if (ok && !input.isClosed) {
        input.sleep = true;
        input.handle(parse);
        return;
      }

      input.buffering--;
      if (state.pos != pos) {
        onDone(Result(source.substring(pos - start, state.pos - start)));
      } else {
        state.fail<Object?>(ErrorUnexpectedCharacter(c));
        state.pos = pos;
        onDone(null);
      }
    }

    parse();
  }
}
