import 'parser_combinator.dart';
import 'runtime.dart';
import 'streaming.dart';

class Breakpoints {
  final _breakpoints = <({String? name, int? pos})>{};

  void add({String? name, int? pos}) {
    _breakpoints.add((name: name, pos: pos));
  }

  bool check({String? name, int? pos}) {
    if (_breakpoints.contains((name: name, pos: pos))) {
      return true;
    }

    for (final element in _breakpoints) {
      if (name == element.name) {
        if (element.pos == null) {
          return true;
        }

        if (element.pos == pos) {
          return true;
        }
      }

      if (pos == element.pos) {
        if (element.name == null) {
          return true;
        }

        if (element.name == name) {
          return true;
        }
      }
    }

    return false;
  }
}

class TracerBuilder<I> {
  final bool Function<O>(Parser<I, O> parser, State<I> state) _fastParse;

  final bool Function<O>(Parser<I, O> parser)? _filter;

  final Result<O>? Function<O>(Parser<I, O> parser, State<I> state) _parse;

  const TracerBuilder({
    required bool Function<O>(Parser<I, O> parser, State<I> state) fastParse,
    bool Function<O>(Parser<I, O> parser)? filter,
    required Result<O>? Function<O>(Parser<I, O> parser, State<I> state) parse,
  })  : _fastParse = fastParse,
        _filter = filter,
        _parse = parse;

  Parser<I, O> build<O>(Parser<I, O> parser) {
    final builder = ParserBuilder<I>(_build);
    final newParser = builder.build(parser);
    return newParser;
  }

  Parser<I, O> _build<O>(ParserBuilder<I> builder, Parser<I, O> parser) {
    final newParser = parser.build(builder);
    if (_filter != null) {
      if (!_filter!(parser)) {
        return newParser;
      }
    }

    return _Tracer(newParser, _fastParse, _parse);
  }
}

class _Tracer<I, O> extends Parser<I, O> {
  final bool Function<O>(Parser<I, O> parser, State<I> state) _fastParse;

  final Result<O>? Function<O>(Parser<I, O> parser, State<I> state) _parse;

  final Parser<I, O> parser;

  _Tracer(this.parser, this._fastParse, this._parse);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return _Tracer(parser, _fastParse, _parse);
  }

  @override
  bool fastParse(State<I> state) {
    return _fastParse(parser, state);
  }

  @override
  Result<O>? parse(State<I> state) {
    return _parse(parser, state);
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<O> onDone) {
    return parseStream(state, onDone);
  }
}
