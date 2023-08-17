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

    if (tag.isEmpty) {
      onDone(Result(tag));
      return;
    }

    final input = state.input;
    input.buffering++;
    void parse() {
      if (input.isIncomplete(state.pos + tag.length)) {
        input.sleep = true;
        input.handle(parse);
        return;
      }

      final data = input.data;
      final source = data.source!;
      if (source.startsWith(tag, state.pos - input.start)) {
        state.pos += tag.length;
        input.buffering--;
        onDone(Result(tag));
        return;
      }

      state.fail<Object?>(ErrorExpectedTag(tag));
      input.buffering--;
      onDone(null);
      return;
    }

    parse();
  }
}
