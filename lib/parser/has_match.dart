import '../parser_combinator.dart';
import '../runtime.dart';

class HasMatch<O>
    extends Parser<StringReader, ({int start, int end, String value})> {
  final Parser<StringReader, O> p;

  const HasMatch(this.p, {String? name}) : super(name);

  @override
  Parser<StringReader, ({int start, int end, String value})> build(
      ParserBuilder<StringReader> builder) {
    return HasMatch(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    final length = input.length;
    final pos = state.pos;
    if (state.pos < length) {
      while (state.pos < length) {
        final r = p.parse(state);
        if (r == null) {
          input.readChar(state.pos);
          state.pos += input.count;
        } else {
          return true;
        }
      }
    }

    state.pos = pos;
    state.fail<Object?>(const ErrorUnexpectedEndOfInput());
    return false;
  }

  @override
  Result<({int start, int end, String value})>? parse(
      State<StringReader> state) {
    final input = state.input;
    final length = input.length;
    final pos = state.pos;
    if (state.pos < length) {
      while (state.pos < length) {
        final start = state.pos;
        final r = p.parse(state);
        if (r == null) {
          input.readChar(state.pos);
          state.pos += input.count;
        } else {
          final v = input.substring(start, state.pos);
          return Result((start: start, end: state.pos, value: v));
        }
      }
    }

    state.pos = pos;
    return state.fail(const ErrorUnexpectedEndOfInput());
  }
}
