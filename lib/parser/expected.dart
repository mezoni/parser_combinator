import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

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

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O>();
    late AsyncResult<O> r1;
    final failPos = state.failPos;
    final errorCount = state.errorCount;
    var action = 0;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = p.parseAsync(state);
            action = 1;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 1:
            if ((result.ok = r1.ok) == true) {
              result.value = r1.value;
            } else {
              if (state.canHandleError(failPos, errorCount)) {
                if (state.pos == state.failPos) {
                  state.clearErrors(failPos, errorCount);
                  state.fail<Object?>(ErrorExpectedTag(tag));
                }
              }
            }

            state.input.handler = result.handler;
            action = -1;
            return;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}
