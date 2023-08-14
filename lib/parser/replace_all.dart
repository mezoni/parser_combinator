import '../parser_combinator.dart';
import '../runtime.dart';
import '../string_reader.dart';

class ReplaceAll<O> extends Parser<StringReader, String> {
  final String Function(String) f;

  final Parser<StringReader, O> p;

  const ReplaceAll(this.p, this.f, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return ReplaceAll(name: name, builder.build(p), f);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    final length = input.length;
    while (true) {
      final start = state.pos;
      final r = p.parse(state);
      if (r != null) {
        final s = input.substring(start, state.pos);
        f(s);
      }

      if (state.pos >= length) {
        break;
      }

      if (state.pos == start) {
        input.readChar(state.pos);
        state.pos += input.count;
      }
    }

    return true;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final input = state.input;
    final length = input.length;
    final list = <String>[];
    var last = state.pos;
    while (true) {
      final start = state.pos;
      final r = p.parse(state);
      if (r != null) {
        if (start != last) {
          list.add(input.substring(last, start));
        }

        last = state.pos;
        final s = input.substring(start, state.pos);
        final v = f(s);
        if (v.isNotEmpty) {
          list.add(v);
        }
      }

      if (state.pos >= length) {
        break;
      }

      if (state.pos == start) {
        input.readChar(state.pos);
        state.pos += input.count;
      }
    }

    if (state.pos != last) {
      list.add(input.substring(last, state.pos));
    }

    switch (list.length) {
      case 0:
        return const Result('');
      case 1:
        return Result(list[0]);
      default:
        return Result(list.join());
    }
  }
}
