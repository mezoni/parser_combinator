import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class TakeWhile extends Parser<StringReader, String> {
  final Predicate<int> f;

  const TakeWhile(this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return TakeWhile(name: name, f);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    while (state.pos < input.length) {
      final c = input.readChar(state.pos);
      if (!f(c)) {
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
      if (!f(c)) {
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
    final p = _AsyncTakeWhileParser(f);
    p.parseAsync(state, onDone);
  }
}

class _AsyncTakeWhileParser extends ChunkedDataParser<String> {
  final Predicate<int> f;

  final List<int> charCodes = [];

  _AsyncTakeWhileParser(this.f);

  @override
  void onError(State<ChunkedData<StringReader>> state) {
    state.fail<Object?>(const ErrorUnknownError());
  }

  @override
  bool? parseChar(int c) {
    if (f(c)) {
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
