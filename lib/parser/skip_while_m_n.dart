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
}
