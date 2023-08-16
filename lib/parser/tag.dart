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
      State<ChunkedData<StringReader>> state, ResultCallback<String> onDone) {
    if (!backtrack(state)) {
      onDone(null);
      return;
    }

    final input = state.input;
    final pos = state.pos;
    var offset = 0;
    input.buffering++;
    bool parse() {
      final data = input.data;
      final start = input.start;
      final end = start + data.length;
      if (offset == 0 && pos + tag.length <= end) {
        input.buffering--;
        if (data.startsWith(tag, state.pos)) {
          state.pos += data.count;
          onDone(Result(tag));
        } else {
          state.fail<Object?>(ErrorExpectedTag(tag));
          onDone(null);
        }

        return true;
      }

      for (; offset < tag.length && state.pos < end;) {
        final c = data.readChar(state.pos - start);
        if (c != tag.runeAt(offset)) {
          break;
        }

        state.pos += data.count;
        offset += data.count;
      }

      if (offset == tag.length) {
        input.buffering--;
        onDone(Result(tag));
        return true;
      }

      if (!input.isClosed) {
        input.listen(parse);
        return false;
      }

      input.buffering--;
      state.pos = pos;
      state.fail<Object?>(ErrorExpectedTag(tag));
      onDone(null);
      return true;
    }

    parse();
  }
}
