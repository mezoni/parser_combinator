import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class SkipWhileMN extends Parser<StringReader, String> {
  final Predicate<int> f;

  final int m;

  final int n;

  const SkipWhileMN(this.m, this.n, this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return SkipWhileMN(name: name, m, n, f);
  }

  @override
  bool fastParse(State<StringReader> state) {
    if (m > n) {
      throw RangeError.range(m, 0, n, 'm');
    }

    final input = state.input;
    final pos = state.pos;
    var count = 0;
    while (count < n && state.pos < input.length) {
      final c = input.readChar(state.pos);
      final v = f(c);
      if (!v) {
        break;
      }

      state.pos += input.count;
      count++;
    }

    if (count >= m) {
      return true;
    }

    final failPos = state.pos;
    state.pos = pos;
    state.failAt<Object?>(failPos, const ErrorUnexpectedCharacter());
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    if (m > n) {
      throw RangeError.range(m, 0, n, 'm');
    }

    final input = state.input;
    final pos = state.pos;
    var count = 0;
    while (count < n && state.pos < input.length) {
      final c = input.readChar(state.pos);
      final v = f(c);
      if (!v) {
        break;
      }

      state.pos += input.count;
      count++;
    }

    if (count >= m) {
      return const Result('');
    }

    final failPos = state.pos;
    state.pos = pos;
    return state.failAt(failPos, const ErrorUnexpectedCharacter());
  }

  @override
  void parseAsync(
      State<ChunkedData<StringReader>> state, ResultCallback<String> onDone) {
    if (m > n) {
      throw RangeError.range(m, 0, n, 'm');
    }

    if (!backtrack(state)) {
      onDone(null);
      return;
    }

    final input = state.input;
    final pos = state.pos;
    final charCodes = <int>[];
    input.buffering++;
    bool parse() {
      final data = input.data;
      final start = input.start;
      final end = start + data.length;
      int? c;
      while (charCodes.length < n && state.pos < end) {
        c = data.readChar(state.pos - start);
        if (!f(c)) {
          break;
        }

        state.pos += data.count;
        charCodes.add(c);
      }

      if (!input.isClosed) {
        input.listen(parse);
        return false;
      }

      input.buffering--;
      if (charCodes.length >= m) {
        onDone(const Result(''));
      } else {
        state.fail<Object?>(ErrorUnexpectedCharacter(c));
        state.pos = pos;
        onDone(null);
      }

      return true;
    }

    parse();
  }
}
