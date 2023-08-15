import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Satisfy extends Parser<StringReader, int> {
  final Predicate<int> f;

  const Satisfy(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, int> build(ParserBuilder<StringReader> builder) {
    return Satisfy(name: name, f);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    if (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (f(c)) {
        state.pos += input.count;
        return true;
      }
    }

    state.fail<Object?>(ErrorUnexpectedCharacter());
    return false;
  }

  @override
  Result<int>? parse(State<StringReader> state) {
    final input = state.input;
    if (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (f(c)) {
        state.pos += input.count;
        return Result(c);
      }
    }

    return state.fail(ErrorUnexpectedCharacter());
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, VoidCallback1<int> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final pos = state.pos;
    final position = input.position;
    final index = input.index;
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

        input.index += chunk.count;
        state.pos += chunk.count;
        input.buffering--;
        onDone(Result(c));
        return true;
      }

      if (!ok || input.isClosed) {
        input.buffering--;
        input.position = position;
        input.index = index;
        state.pos = pos;
        state.fail<Object?>(ErrorUnexpectedCharacter(c));
        onDone(null);
        return true;
      }

      input.listen(parse);
      return false;
    }

    parse();
  }
}
