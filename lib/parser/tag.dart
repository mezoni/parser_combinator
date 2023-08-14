import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';
import '../string_reader.dart';

class Tag extends Parser<StringReader, String> {
  final String tag;

  const Tag(this.tag, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Tag(name: name, tag);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    if (input.startsWith(tag, pos)) {
      state.pos += input.count;
      return true;
    }

    state.fail<Object?>(ErrorExpectedTag(tag));
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    if (input.startsWith(tag, pos)) {
      state.pos += input.count;
      return Result(tag);
    }

    return state.fail(ErrorExpectedTag(tag));
  }

  @override
  void parseStream(
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    var count = 0;
    input.buffering++;
    bool parse() {
      if (input.index0 < input.start) {
        input.buffering--;
        input.index0 = index0;
        input.index1 = index1;
        input.index2 = index2;
        state.failAt<Object?>(state.failPos, ErrorBacktrackingError(state.pos));
        state.pos = pos;
        onDone(null);
        return true;
      }

      var ok = true;
      while (input.index1 < buffer.length) {
        final chunk = buffer[input.index1];
        if (input.index2 >= chunk.length) {
          input.index0++;
          input.index1++;
          input.index2 = 0;
          continue;
        }

        final c = chunk.readChar(input.index2);
        if (c != tag.runeAt(count)) {
          ok = false;
          break;
        }

        count++;
        input.index2 += chunk.count;
        state.pos += chunk.count;
        if (count == tag.length) {
          input.buffering--;
          onDone(Result(tag));
          return true;
        }
      }

      if (!ok || input.isClosed) {
        input.buffering--;
        input.index0 = index0;
        input.index1 = index1;
        input.index2 = index2;
        state.pos = pos;
        state.fail<Object?>(ErrorExpectedTag(tag));
        onDone(null);
        return true;
      }

      input.listen(parse);
      return false;
    }

    parse();
  }
}
