import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Ref<I, O> extends Parser<I, O> {
  final Parser<I, O> Function() f;

  const Ref(this.f, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    final p = f();
    final ref = _Ref<I, O>(name: name);
    builder.processed[this] = ref;
    final p2 = builder.build(p);
    ref.p = p2;
    return ref;
  }

  @override
  bool fastParse(State<I> state) {
    final p = f();
    return p.fastParse(state);
  }

  @override
  Result<O>? parse(State<I> state) {
    final p = f();
    return p.parse(state);
  }

  @override
  void parseAsync(State<ChunkedData<I>> state, ResultCallback<O> onDone) {
    final p = f();
    p.parseAsync(state, onDone);
  }
}

class _Ref<I, O> extends Parser<I, O> {
  Parser<I, O>? p;

  _Ref({String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    final ref = _Ref<I, O>(name: name);
    builder.processed[this] = ref;
    final p2 = p!.build(builder);
    ref.p = p2;
    return ref;
  }

  @override
  bool fastParse(State<I> state) {
    return p!.fastParse(state);
  }

  @override
  Result<O>? parse(State<I> state) {
    return p!.parse(state);
  }

  @override
  void parseAsync(State<ChunkedData<I>> state, ResultCallback<O> onDone) {
    p!.parseAsync(state, onDone);
  }
}
