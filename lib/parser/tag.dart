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
    final p = _AsyncTagParser(tag);
    p.parseAsync(state, onDone);
  }
}

class _AsyncTagParser extends ChunkedDataParser<String> {
  int count = 0;

  final String tag;

  _AsyncTagParser(this.tag);

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(ErrorExpectedTag(tag));
  }

  @override
  bool? parseChar(int c) {
    if (count > tag.length) {
      return false;
    }

    if (c != tag.runeAt(count++)) {
      return false;
    }

    if (count == tag.length) {
      result = Result(tag);
      return true;
    }

    return null;
  }
}
