import '../parser_combinator.dart';
import '../runtime.dart';

class Expected<I, O> extends Parser<I, O> {
  final Parser<I, O> p;

  final String tag;

  const Expected(this.p, this.tag, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Expected(name: name, p.build(builder), tag);
  }

  @override
  bool fastParse(State<I> state) {
    final failPos = state.failPos;
    final errorCount = state.errorCount;
    final r = p.fastParse(state);
    if (r) {
      return true;
    }

    if (state.canHandleError(failPos, errorCount)) {
      if (state.pos == state.failPos) {
        state.clearErrors(failPos, errorCount);
        state.fail<Object?>(ErrorExpectedTag(tag));
      }
    }

    return false;
  }

  @override
  Result<O>? parse(State<I> state) {
    final failPos = state.failPos;
    final errorCount = state.errorCount;
    final r = p.parse(state);
    if (r != null) {
      return r;
    }

    if (state.canHandleError(failPos, errorCount)) {
      if (state.pos == state.failPos) {
        state.clearErrors(failPos, errorCount);
        state.fail<Object?>(ErrorExpectedTag(tag));
      }
    }

    return null;
  }
}