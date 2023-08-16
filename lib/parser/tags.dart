import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Tags extends Parser<StringReader, String> {
  final List<String> tags;

  const Tags(this.tags, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Tags(name: name, tags);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    for (var i = 0; i < tags.length; i++) {
      final tag = tags[i];
      if (input.startsWith(tag, state.pos)) {
        state.pos += input.count;
        return true;
      }
    }

    state.fail<Object?>(ErrorExpectedTags(tags));
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final input = state.input;
    for (var i = 0; i < tags.length; i++) {
      final tag = tags[i];
      if (input.startsWith(tag, state.pos)) {
        state.pos += input.count;
        return Result(tag);
      }
    }

    return state.fail(ErrorExpectedTags(tags));
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, ResultCallback<String> onDone) {
    if (!backtrack(state)) {
      onDone(null);
      return;
    }

    if (tags.isEmpty) {
      state.fail<Object?>(ErrorExpectedTags(tags));
      onDone(null);
    }

    final input = state.input;
    final pos = state.pos;
    var index = 0;
    var offset = 0;
    input.buffering++;
    bool parse() {
      final data = input.data;
      final start = input.start;
      final end = start + data.length;
      for (; index < tags.length; index++) {
        final tag = tags[index];
        if (offset == 0 && pos + tag.length <= end) {
          if (data.startsWith(tag, state.pos)) {
            input.buffering--;
            state.pos += data.count;
            onDone(Result(tag));
            return true;
          }
        }

        for (; offset < tag.length && state.pos < end; offset) {
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
      }

      input.buffering--;
      state.pos = pos;
      state.fail<Object?>(ErrorExpectedTags(tags));
      onDone(null);
      return true;
    }

    parse();
  }
}
