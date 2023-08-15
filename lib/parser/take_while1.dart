import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class TakeWhile1 extends Parser<StringReader, String> {
  final Predicate<int> f;

  const TakeWhile1(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return TakeWhile1(name: name, f);
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
        ? Result(input.substring(pos, state.pos))
        : state.fail(const ErrorUnexpectedCharacter());
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final position = input.position;
    final index = input.index;
    final pos = state.pos;
    final charCodes = <int>[];
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

      int? c;
      var ok = true;
      while (i < buffer.length) {
        final chunk = buffer[i];
        if (input.index >= chunk.length) {
          i++;
          input.position++;
          input.index = 0;
          continue;
        }

        c = chunk.readChar(input.index);
        if (!f(c)) {
          ok = false;
          break;
        }

        charCodes.add(c);
        input.index += chunk.count;
        state.pos += chunk.count;
      }

      if (!ok || input.isClosed) {
        input.buffering--;
        if (charCodes.isNotEmpty) {
          onDone(Result(String.fromCharCodes(charCodes)));
          return true;
        } else {
          input.position = position;
          input.index = index;
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
