import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Digit extends Parser<StringReader, String> {
  const Digit({String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Digit(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!(c >= 0x30 && c <= 0x39)) {
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
      if (!(c >= 0x30 && c <= 0x39)) {
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
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final position = input.position;
    final index = input.index;
    final pos = state.pos;
    final charCodes = <int>[];
    input.buffering++;
    bool parse() {
      var i = input.position - input.start;
      if (i < 0) {
        input.buffering--;
        input.position = position;
        input.index = index;
        state.failAt<Object?>(state.failPos, ErrorBacktrackingError(state.pos));
        state.pos = pos;
        onDone(null);
        return true;
      }

      while (i < buffer.length) {
        final chunk = buffer[i];
        if (input.index >= chunk.length) {
          i++;
          input.position++;
          input.index = 0;
          continue;
        }

        final c = chunk.readChar(input.index);
        if (!(c >= 0x30 && c <= 0x39)) {
          input.buffering--;
          final value =
              charCodes.isNotEmpty ? String.fromCharCodes(charCodes) : '';
          onDone(Result(value));
          return true;
        }

        charCodes.add(c);
        input.index += chunk.count;
        state.pos += chunk.count;
      }

      if (input.isClosed) {
        input.buffering--;
        final value =
            charCodes.isNotEmpty ? String.fromCharCodes(charCodes) : '';
        onDone(Result(value));
        return true;
      }

      input.listen(parse);
      return false;
    }

    parse();
  }
}
