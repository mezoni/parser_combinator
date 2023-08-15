import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Alpha1 extends Parser<StringReader, String> {
  const Alpha1({String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Alpha1(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!(c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A)) {
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
      if (!(c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A)) {
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
    final p = _AsyncAlpha1Parser();
    p.parseAsync(state, onDone);
  }
}

class _AsyncAlpha1Parser extends ChunkedDataParser<String> {
  final List<int> charCodes = [];

  int? c;

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(ErrorUnexpectedCharacter(c));
  }

  @override
  bool? parseChar(int c) {
    if (c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A) {
      charCodes.add(c);
      return null;
    }

    this.c = c;
    return false;
  }

  @override
  bool parseError() {
    if (charCodes.isEmpty) {
      return false;
    }

    final value = String.fromCharCodes(charCodes);
    result = Result(value);
    return true;
  }
}
