import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';
import '../string_reader.dart';

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
  void parseStream(
      State<ChunkedData<StringReader>> state, VoidCallback1<int> onDone) {
    final input = state.input;
    final buffer = input.buffer;
    final pos = state.pos;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    input.buffering++;
    bool parse() {
      if (input.index0 < input.start) {
        throw UnimplementedError();
      }

      var ok = true;
      int? c;
      while (input.index1 < buffer.length) {
        final chunk = buffer[input.index1];
        if (input.index2 >= chunk.length) {
          input.index0++;
          input.index1++;
          input.index2 = 0;
          continue;
        }

        c = chunk.readChar(input.index2);
        if (!f(c)) {
          ok = false;
          break;
        }

        input.index2 += chunk.count;
        state.pos += chunk.count;
        input.buffering--;
        onDone(Result(c));
        return true;
      }

      if (!ok || input.isClosed) {
        input.buffering--;
        input.index0 = index0;
        input.index1 = index1;
        input.index2 = index2;
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
