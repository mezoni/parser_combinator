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
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final p = _AsyncTagsParser(tags);
    p.parseAsync(state, onDone);
  }
}

class _AsyncTagsParser extends ChunkedDataParser<String> {
  int count = 0;

  int tagIndex = 0;

  final List<String> tags;

  _AsyncTagsParser(this.tags);

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(ErrorExpectedTags(tags));
  }

  @override
  bool? parseChar(int c) {
    if (tagIndex >= tags.length) {
      return false;
    }

    final tag = tags[tagIndex];
    if (c != tag.runeAt(count++)) {
      return false;
    }

    if (count == tag.length) {
      result = Result(tag);
      return true;
    }

    return null;
  }

  @override
  bool? parseError() {
    if (tagIndex >= tags.length) {
      return false;
    }

    tagIndex++;
    count = 0;
    return null;
  }
}
