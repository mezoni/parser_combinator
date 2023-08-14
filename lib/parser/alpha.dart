import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';
import '../string_reader.dart';

class Alpha extends Parser<StringReader, String> {
  const Alpha({String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Alpha(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!(c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A)) {
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
      if (!(c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A)) {
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

      var index = input.index0 - input.start;
      while (index < buffer.length) {
        final chunk = buffer[index];
        if (input.index1 >= chunk.length) {
          index++;
          input.index0++;
          input.index1 = 0;
          continue;
        }

        final c = chunk.readChar(input.index1);
        if (!(c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A)) {
          input.buffering--;
          final value =
              charCodes.isNotEmpty ? String.fromCharCodes(charCodes) : '';
          onDone(Result(value));
          return true;
        }

        charCodes.add(c);
        input.index1 += chunk.count;
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
