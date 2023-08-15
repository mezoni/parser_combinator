import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

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
  void parseAsync(
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final position = input.position;
    final index = input.index;
    final pos = state.pos;
    var count = 0;
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

      var ok = true;
      while (i < buffer.length) {
        final chunk = buffer[i];
        if (input.index >= chunk.length) {
          i++;
          input.position++;
          input.index = 0;
          continue;
        }

        final c = chunk.readChar(input.index);
        if (c != tag.runeAt(count)) {
          ok = false;
          break;
        }

        count++;
        input.index += chunk.count;
        state.pos += chunk.count;
        if (count == tag.length) {
          input.buffering--;
          onDone(Result(tag));
          return true;
        }
      }

      if (!ok || input.isClosed) {
        input.buffering--;
        input.position = position;
        input.index = index;
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
