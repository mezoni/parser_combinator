import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Proc<I> extends Parser<I, Object?> {
  final void Function() f;

  const Proc(this.f, {String? name}) : super(name);

  @override
  Parser<I, Object?> build(ParserBuilder<I> builder) {
    return Proc(name: name, f);
  }

  @override
  bool fastParse(State<I> state) {
    f();
    return true;
  }

  @override
  Result<Object?>? parse(State<I> state) {
    f();
    return const Result(null);
  }

  @override
  void parseAsync(State<ChunkedData<I>> state, ResultCallback<Object?> onDone) {
    f();
    onDone(Result(null));
  }
}
