import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Digit extends Parser<StringReader, String> {
  const Digit({String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Digit(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!(c >= 0x30 && c <= 0x39)) {
        break;
      }

      state.pos += input.count;
    }

    return true;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final input = state.input;
    final pos = state.pos;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!(c >= 0x30 && c <= 0x39)) {
        break;
      }

      state.pos += input.count;
    }

    return state.pos != pos
        ? Result(input.substring(pos, state.pos))
        : const Result('');
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, VoidCallback1<String> onDone) {
    final p = _AsyncDigitParser();
    p.parseAsync(state, onDone);
  }
}

class _AsyncDigitParser extends ChunkedDataParser<String> {
  final List<int> charCodes = [];

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(const ErrorUnknownError());
  }

  @override
  bool? parseChar(int c) {
    if (c >= 0x30 && c <= 0x39) {
      charCodes.add(c);
      return null;
    }

    return false;
  }

  @override
  bool parseError() {
    final value = charCodes.isNotEmpty ? String.fromCharCodes(charCodes) : '';
    result = Result(value);
    return true;
  }
}
