import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';
import '../string_reader.dart';

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
  void parseStream(
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final index0 = input.index0;
    final index2 = input.index2;
    final pos = state.pos;
    final charCodes = <int>[];
    input.buffering++;
    bool parse() {
      if (input.index0 < input.start) {
        input.buffering--;
        input.index0 = index0;
        input.index2 = index2;
        state.failAt<Object?>(state.failPos, ErrorBacktrackingError(state.pos));
        state.pos = pos;
        onDone(null);
        return true;
      }

      var index = input.index0 - input.start;
      while (index < buffer.length) {
        final chunk = buffer[index];
        if (input.index2 >= chunk.length) {
          index++;
          input.index0++;
          input.index2 = 0;
          continue;
        }

        final c = chunk.readChar(input.index2);
        if (!f(c)) {
          input.buffering--;
          onDone(Result(String.fromCharCodes(charCodes)));
          return true;
        }

        charCodes.add(c);
        input.index2 += chunk.count;
        state.pos += chunk.count;
      }

      if (input.isClosed) {
        input.buffering--;
        onDone(Result(String.fromCharCodes(charCodes)));
        return true;
      }

      input.listen(parse);
      return false;
    }

    parse();
  }
}
