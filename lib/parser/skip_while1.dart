import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';
import '../string_reader.dart';

class SkipWhile1 extends Parser<StringReader, String> {
  final Predicate<int> f;

  const SkipWhile1(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return SkipWhile1(name: name, f);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!f(c)) {
        break;
      }

      state.pos += input.count;
    }

    if (state.pos != pos) {
      return true;
    }

    state.fail<Object?>(const ErrorUnexpectedCharacter());
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!f(c)) {
        break;
      }

      state.pos += input.count;
    }

    return state.pos != pos
        ? const Result('')
        : state.fail(const ErrorUnexpectedCharacter());
  }

  @override
  void parseStream(
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final index0 = input.index0;
    final index2 = input.index2;
    final pos = state.pos;
    var count = 0;
    input.buffering++;
    bool parse() {
      if (input.index0 < input.start) {
        input.buffering--;
        input.index0 = index0;
        input.index2 = index2;
        state.failAt<Object?>(state.failPos, ErrorBacktrackingError(state.pos));
        state.pos = pos;
        onDone(null);
        return true;
      }

      var ok = true;
      var index = input.index0 - input.start;
      int? c;
      while (index < buffer.length) {
        final chunk = buffer[index];
        if (input.index2 >= chunk.length) {
          index++;
          input.index0++;
          input.index2 = 0;
          continue;
        }

        c = chunk.readChar(input.index2);
        if (!f(c)) {
          ok = false;
          break;
        }

        count++;
        input.index2 += chunk.count;
        state.pos += chunk.count;
      }

      if (!ok || input.isClosed) {
        input.buffering--;
        if (count != 0) {
          onDone(Result(''));
          return true;
        } else {
          input.index0 = index0;
          input.index2 = index2;
          state.pos = pos;
          state.fail<Object?>(ErrorUnexpectedCharacter(c));
          onDone(null);
        }

        return true;
      }

      input.listen(parse);
      return false;
    }

    parse();
  }
}
