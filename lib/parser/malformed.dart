import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Malformed<I, O> extends Parser<I, O> {
  final String message;

  final Parser<I, O> p;

  const Malformed(this.p, this.message, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Malformed(name: name, p.build(builder), message);
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
      if (state.pos != state.failPos) {
        state.clearErrors(failPos, errorCount);
        state.failAt<Object?>(
            state.failPos, ErrorMessage(state.pos - state.failPos, message));
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
      if (state.pos != state.failPos) {
        state.clearErrors(failPos, errorCount);
        state.failAt<Object?>(
            state.failPos, ErrorMessage(state.pos - state.failPos, message));
      }
    }

    return null;
  }

  @override
  void parseAsync(State<ChunkedData<I>> state, VoidCallback1<O> onDone) {
    final failPos = state.failPos;
    final errorCount = state.errorCount;
    void parse() {
      p.parseAsync(state, (result) {
        if (result != null) {
          onDone(result);
        } else {
          if (state.canHandleError(failPos, errorCount)) {
            if (state.pos != state.failPos) {
              state.clearErrors(failPos, errorCount);
              state.failAt<Object?>(state.failPos,
                  ErrorMessage(state.pos - state.failPos, message));
            }
          }

          onDone(null);
        }
      });
    }

    parse();
  }
}
