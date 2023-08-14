import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';
import '../string_reader.dart';

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
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final index0 = input.index0;
    final index1 = input.index1;
    final pos = state.pos;
    final charCodes = <int>[];
    input.buffering++;
    bool parse() {
      if (input.index0 < input.start) {
        input.buffering--;
        input.index0 = index0;
        input.index1 = index1;
        state.failAt<Object?>(state.failPos, ErrorBacktrackingError(state.pos));
        state.pos = pos;
        onDone(null);
        return true;
      }

      var ok = true;
      var index = input.index0 - input.start;
      int? c;
      while (index < buffer.length) {
        final chunk = buffer[index];
        if (input.index1 >= chunk.length) {
          index++;
          input.index0++;
          input.index1 = 0;
          continue;
        }

        c = chunk.readChar(input.index1);
        if (!(c >= 0x30 && c <= 0x39)) {
          ok = false;
          break;
        }

        charCodes.add(c);
        input.index1 += chunk.count;
        state.pos += chunk.count;
      }

      if (!ok || input.isClosed) {
        input.buffering--;
        if (charCodes.isNotEmpty) {
          onDone(Result(String.fromCharCodes(charCodes)));
          return true;
        } else {
          input.index0 = index0;
          input.index1 = index1;
          state.pos = pos;
          state.fail<Object?>(ErrorUnexpectedCharacter(c));
          onDone(null);
        }

        return true;
      }

      input.listen(parse);
      return false;
    }

    parse();
  }
}
