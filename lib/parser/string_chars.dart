import '../parser_combinator.dart';
import '../runtime.dart';

class StringChars extends Parser<StringReader, String> {
  final bool Function(int) isNormalChar;

  final int controlChar;

  final Parser<StringReader, String> escapeChar;

  const StringChars(this.isNormalChar, this.controlChar, this.escapeChar,
      {String? name})
      : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return StringChars(
        name: name, isNormalChar, controlChar, builder.build(escapeChar));
  }

  @override
  bool fastParse(State<StringReader> state) {
    final input = state.input;
    while (state.pos < input.length) {
      final pos = state.pos;
      var c = -1;
      while (state.pos < input.length) {
        c = input.readChar(state.pos);
        final ok = isNormalChar(c);
        if (!ok) {
          break;
        }

        state.pos += input.count;
      }

      if (c != controlChar) {
        break;
      }

      state.pos += 1;
      final r = escapeChar.fastParse(state);
      if (!r) {
        state.pos = pos;
        break;
      }
    }

    return true;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final input = state.input;
    final list = <String>[];
    var str = '';
    while (state.pos < input.length) {
      final pos = state.pos;
      str = '';
      var c = -1;
      while (state.pos < input.length) {
        c = input.readChar(state.pos);
        final ok = isNormalChar(c);
        if (!ok) {
          break;
        }

        state.pos += input.count;
      }

      if (state.pos != pos) {
        str = input.substring(pos, state.pos);
        if (list.isNotEmpty) {
          list.add(str);
        }
      }

      if (c != controlChar) {
        break;
      }

      state.pos += 1;
      final r = escapeChar.parse(state);
      if (r == null) {
        state.pos = pos;
        break;
      }

      if (list.isEmpty && str != '') {
        list.add(str);
      }

      list.add(r.value);
    }

    if (list.isEmpty) {
      return Result(str);
    }

    return Result(list.join());
  }
}
