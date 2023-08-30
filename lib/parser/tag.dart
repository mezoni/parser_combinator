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
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<String>();
    if (!backtrack(state)) {
      result.ok = false;
      return result;
    }

    final input = state.input;
    input.buffering++;

    final data = input.data;
    final source = data.source!;
    final end = input.end;
    if (state.pos + tag.length <= end) {
      input.buffering--;
      if (result.ok = source.startsWith(tag, state.pos - input.start)) {
        state.pos += tag.length;
        result.value = Result(tag);
      } else {
        state.fail<Object?>(ErrorExpectedTag(tag));
      }

      input.handler = result.handler;
      return result;
    }

    void parse() {
      final end = input.end;
      while (state.pos + tag.length > end && !input.isClosed) {
        input.sleep = true;
        input.handler = parse;
        return;
      }

      input.buffering--;
      final data = input.data;
      final source = data.source!;
      if (result.ok = source.startsWith(tag, state.pos - input.start)) {
        state.pos += tag.length;
        result.value = Result(tag);
      } else {
        state.fail<Object?>(ErrorExpectedTag(tag));
      }

      input.handler = result.handler;
    }

    parse();
    return result;
  }
}
