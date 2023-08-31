import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

/// Applies a predicate [f] to each parsed character and consumes input if the
/// predicate returns true, at least [m] and no more than [n] characters.
///
/// Parsing succeeds if enough characters have been consumed (>= m && <= n).
///
/// Otherwise, parsing fails with the error [ErrorUnexpectedCharacter].
///
/// Returns: A string consisting of the consumed characters.
class TakeWhileMN extends Parser<StringReader, String> {
  final Predicate<int> f;

  final int m;

  final int n;

  const TakeWhileMN(this.m, this.n, this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return TakeWhileMN(name: name, m, n, f);
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
      return state.pos != pos
          ? Result(input.substring(pos, state.pos))
          : const Result('');
    }

    final failPos = state.pos;
    state.pos = pos;
    return state.failAt(failPos, const ErrorUnexpectedCharacter());
  }
}
