import '../parser/choice.dart';
import '../parser/delimited.dart';
import '../parser/digit.dart';
import '../parser/digit1.dart';
import '../parser/eof.dart';
import '../parser/expected.dart';
import '../parser/fast.dart';
import '../parser/malformed.dart';
import '../parser/map.dart';
import '../parser/opt.dart';
import '../parser/preceded.dart';
import '../parser/predicate.dart';
import '../parser/recognize.dart';
import '../parser/ref.dart';
import '../parser/satisfy.dart';
import '../parser/separated_list.dart';
import '../parser/separated_pair.dart';
import '../parser/sequence.dart';
import '../parser/skip_while.dart';
import '../parser/string_chars.dart';
import '../parser/tag.dart';
import '../parser/tags.dart';
import '../parser/take_while_m_n.dart';
import '../parser/terminated.dart';
import '../parser/tuple.dart';
import '../parser/value.dart';
import '../parser/wrapper.dart';
import '../parser_combinator.dart';
import '../parsing.dart';
import '../runtime.dart';

void main(List<String> args) {
  const source = '{"rocket": "🚀 flies to the stars"}';
  final input = StringReader(source);
  final result = parseInput(parser.parse, input);
  print(result);
}

const parser = Delimited(name: 'parser', _ws, _value, Eof());

const _array = Delimited(name: '_array', _openBracket, _values, _closeBracket);

const _arrayElement = Wrapper(name: '_arrayElement', _value);

const _closeBrace = Terminated(name: '_closeBrace', Tag('}'), _ws);

const _closeBracket = Terminated(name: '_closeBracket', Tag(']'), _ws);

const _colon = Terminated(name: '_colon', Tag(':'), _ws);

const _comma = Terminated(name: '_comma', Tag(','), _ws);

const _digit1 = Expected(name: '_digit1', Digit1(), 'decimal digit');

const _doubleQuote = Terminated(name: '_doubleQuote', Tag('"'), _ws);

const _escape = _Escape(name: '_escape');

const _escapeHexValue = Map1(
    name: '_escapeHexValue',
    Preceded(Tag('u'), _hexValueChecked),
    createStringFromHexValue);

const _exponent =
    Tuple3(name: '_exponent', Tags(['E', 'e']), Opt(Tags(['-', '+'])), _digit1);

const _false = ValueP(name: '_false', false, Terminated(Tag('false'), _ws));

const _fraction = Tuple2(name: '_fraction', Tag('.'), _digit1);

const _hexValue = TakeWhileMN(name: '_hexValue', 4, 4, isHexDigit);

const _hexValueChecked = Malformed(
    name: '_hexValueChecked', _hexValue, 'Expected 4 digit hexadecimal number');

const _integer = Recognize2(
    name: '_integer',
    Opt(Tag('-')),
    Choice2(
      Tag('0'),
      Sequence2(Satisfy(isDigit1_9), Digit()),
    ));

const _keyValue = Map1(
    name: '_keyValue',
    SeparatedPair(_objectKey, _colon, _objectValue),
    createMapEntry);

const _keyValues = SeparatedList(name: '_keyValues', _keyValue, _comma);

const _null =
    // ignore: unnecessary_cast
    ValueP(name: '_null', null as Object?, Terminated(Tag('null'), _ws));

const _number = Expected(name: '_number', Terminated(_number_, _ws), 'number');

/// '-'?('0'|[1-9][0-9]*)('.'[0-9]+)?([eE][+-]?[0-9]+)?
const _number_ = Map1(
    name: '_number_',
    Recognize(
      Fast3(
        _integer,
        Opt(_fraction),
        Opt(_exponent),
      ),
    ),
    num.parse);

const _object = Map1(
    name: '_object',
    Delimited(_openBrace, _keyValues, _closeBrace),
    Map.fromEntries);

const _objectKey = Wrapper(name: '_objectKey', _string);

const _objectValue = Wrapper(name: '_objectValue', _value);

const _openBrace = Terminated(name: '_openBrace', Tag('{'), _ws);

const _openBracket = Terminated(name: '_openBracket', Tag('['), _ws);

const _string = Expected(
  name: '_string',
  Delimited(
    Tag('"'),
    StringChars(
      isNormalChar,
      92,
      Choice2(
        _escape,
        _escapeHexValue,
      ),
    ),
    _doubleQuote,
  ),
  'string',
);

const _true = ValueP(name: '_true', true, Terminated(Tag('true'), _ws));

const Parser<StringReader, Object?> _value =
    Ref(name: '_value_', getValueParser);

const _value_ = Choice7(
  name: '_value',
  _object,
  _array,
  _string,
  _number,
  _false,
  _null,
  _true,
);

const _values = SeparatedList(name: '_values', _arrayElement, _comma);

const _ws = SkipWhile(name: '_ws', isWhitespace);

MapEntry<String, Object?> createMapEntry((String, Object?) kv) {
  return MapEntry(kv.$1, kv.$2);
}

String createStringFromHexValue(String s) {
  return String.fromCharCode(toHexValue(s));
}

Parser<StringReader, Object?> getValueParser() => _value_;

bool isDigit1_9(int c) => c >= 0x31 && c <= 0x39;

bool isNormalChar(int c) => c <= 91
    ? c <= 33
        ? c >= 32
        : c >= 35
    : c <= 1114111 && c >= 93;

@pragma('vm:prefer-inline')
int toHexValue(String s) {
  var r = 0;
  for (var i = s.length - 1, j = 0; i >= 0; i--, j += 4) {
    final c = s.codeUnitAt(i);
    final int v;
    if (c >= 0x30 && c <= 0x39) {
      v = c - 0x30;
    } else if (c >= 0x41 && c <= 0x46) {
      v = c - 0x41 + 10;
    } else if (c >= 0x61 && c <= 0x66) {
      v = c - 0x61 + 10;
    } else {
      throw StateError('Internal error');
    }

    r += v * (1 << j);
  }

  return r;
}

class ParserErrorMessages {
  static const expected4DigitHexadecimalNumber =
      'Expected 4 digit hexadecimal number';

  final String text;

  const ParserErrorMessages(this.text);
}

class _Escape extends Parser<StringReader, String> {
  const _Escape({String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return _Escape(name: name);
  }

  @override
  bool fastParse(State<StringReader> state) {
    final r = parse(state);
    return r != null;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final input = state.input;
    final c = input.readChar(state.pos);
    switch (c) {
      case 34:
        state.pos += input.count;
        return const Result('"');
      case 0x2F:
        state.pos += input.count;
        return const Result('/');
      case 0x5C:
        state.pos += input.count;
        return const Result(r'\\');
      case 0x62:
        state.pos += input.count;
        return const Result('\b');
      case 0x66:
        state.pos += input.count;
        return const Result('\f');
      case 0x6E:
        state.pos += input.count;
        return const Result('\n');
      case 0x72:
        state.pos += input.count;
        return const Result('\r');
      case 0x74:
        state.pos += input.count;
        return const Result('\t');
    }

    return state.fail(const ErrorUnexpectedCharacter());
  }
}
