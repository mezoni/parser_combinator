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
    if (tags.isEmpty) {
      throw ArgumentError.value(tags, 'tags', 'Must not be empty');
    }

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
    if (tags.isEmpty) {
      throw ArgumentError.value(tags, 'tags', 'Must not be empty');
    }

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
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    if (tags.isEmpty) {
      throw ArgumentError.value(tags, 'tags', 'Must not be empty');
    }

    final result = AsyncResult<String>();
    if (!backtrack(state)) {
      result.ok = false;
      return result;
    }

    final input = state.input;
    final start = input.start;
    var index = 0;
    input.buffering++;
    void parse() {
      final data = input.data;
      final source = data.source!;
      final end = input.end;
      for (; index < tags.length; index++) {
        final tag = tags[index];
        if (state.pos + tag.length > end && !input.isClosed) {
          input.sleep = true;
          input.handler = parse;
          return;
        }

        if (source.startsWith(tag, state.pos - start)) {
          state.pos += tag.length;
          input.buffering--;
          result.value = Result(tag);
          result.ok = true;
          input.handler = result.handler;
          return;
        }
      }

      state.fail<Object?>(ErrorExpectedTags(tags));
      input.buffering--;
      result.ok = false;
      input.handler = result.handler;
      return;
    }

    parse();
    return result;
  }
}
