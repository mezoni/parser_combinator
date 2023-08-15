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
}

class _AsyncTagsParser extends ChunkedDataParser<String> {
  int count = 0;

  int count2 = 0;

  final List<String> tags;

  _AsyncTagsParser(this.tags);

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(ErrorExpectedTags(tags));
  }

  @override
  bool? parseChar(int c) {
    if (count2 >= tags.length) {
      return false;
    }

    final tag = tags[count2];
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
    if (count2 >= tags.length) {
      return false;
    }

    count2++;
    count = 0;
    return null;
  }
}
