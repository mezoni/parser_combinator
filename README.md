# parser_combinator

Parser combinator is a collection of parsers that can be used to combine basic parsers to create parsers for more complex rules.

Version: 0.2.7

## About

Parser combinator is intended for general purpose use.  
It can be used not only to implement parsers, but also to create validators.  
Combined parser do not require building and can be used immediately.  
The combined parser can be compiled into static code.  
Parsers declared as constants are evaluated at compile time.  
Simple and understandable localization of error messages.  
Fully customizable parsing error tracking system during development for maximum convenience.  
Very handy ways to track down parsing errors when tracing during development.  
Parsing character data not only from strings, but also from any other sources.  

## Parsing

The general rule is that complex parsers are made up of less complex parsers.  
The simpler some part of the parser, the easier it is to imagine how it should work.  
For certain purposes, you can write a custom parser that will parse more efficiently than a combined parser.  
Or, for example, you can implement a basic set for parsing some data (binary or that is directly in the file) and use them to parse such data.  

The simplest parsing example:

```dart
void main(List<String> args) {
  const id = Recognize2(Satisfy(isAlpha), SkipWhile(isAlphanumeric));
  print(parseString(id.parse, 'Abc'));
  print(parseString(id.parse, 'xyz123'));

  print(parseString(calc.parse, '1 + 2 * 3'));
  print(parseString(calc.parse, '(1 + 2) * 3'));
}

const calc = _expr;

const _add = ChainL1(_mul, _addOps, _mul, _toBinary);

const _addOps = Terminated(Tags(['-', '+']), _ws);

const _closeParenthesis = Terminated(Tag(')'), _ws);

const _expr = Ref(_exprRef);

const _mul = ChainL1(_primary, _mulOps, _primary, _toBinary);

const _mulOps = Terminated(Tags(['*', '/']), _ws);

const _number = Terminated(_number_, _ws);

const _number_ = Map1(Recognize2(Opt(Tag('-')), Digit1()), num.parse);

const _openParenthesis = Terminated(Tag('('), _ws);

const _primary =
    Choice2(_number, Delimited(_openParenthesis, _expr, _closeParenthesis));

const _ws = SkipWhile(isWhitespace);

Parser<StringReader, num> _exprRef() => _add;

num _toBinary(num left, String op, num right) {
  return switch (op) {
    '-' => left - right,
    '+' => left + right,
    '*' => left * right,
    '/' => left * right,
    _ => throw ArgumentError.value(op, 'op'),
  };
}

```

## Parsing from files

An example of parsing from a text file.  

```dart
final file = File('test/temp.json');
final fileReader = FileReader(file.openSync(), bufferSize: 1024);
final utf8Reader = Utf8Reader(fileReader);
try {
  return parseInput(json_parser.parser.parse, utf8Reader);
} finally {
  fileReader.fp.closeSync();
}

```

## Localization

Localization is implemented through the use of translation through hash tables.  
Localization is supported at the translation level of error messages and tags used in error messages.  
This approach uses two independent tables.  
One table for translating messages, the other for translating tags.  
Translation is performed only for data for which information for translation is provided.  

A complete example of the simplest parse localization.

```dart
void main(List<String> args) {
  parse(r'"abc\u123xyz"');
  parse('{"abc": `123}');
  parse('1.');
}

void parse(String text) {
  print(text);
  try {
    parseString(parser, text, messages: _messages, tags: _tags);
  } catch (e) {
    print(e);
    print('-' * 40);
  }
}

final _tags = {
  'decimal digit': 'десятичная цифра',
  'number': 'число',
  'string': 'строка',
};

const _messages = {
  ParserErrorMessages.expected4DigitHexadecimalNumber:
      MessageLocalization(other: 'Ожидается 4-значное шестнадцатеричное число'),
  ErrorExpectedCharacter.message:
      MessageLocalization(other: 'Ожидается символ {0}'),
  ErrorExpectedEndOfInput.message:
      MessageLocalization(other: 'Ожидается конец входных данных'),
  ErrorExpectedIntegerValue.message:
      MessageLocalization(other: 'Ожидается целочисленное значение {0}'),
  ErrorExpectedTags.message: MessageLocalization(
    other: 'Ожидаются: {0}',
    one: 'Ожидается: {0}',
  ),
  ErrorUnexpectedCharacter.message:
      MessageLocalization(other: 'Неожиданный символ {0}'),
  ErrorUnexpectedEndOfInput.message:
      MessageLocalization(other: 'Неожиданный конец входных данных'),
  ErrorUnexpectedInput.message:
      MessageLocalization(other: 'Неожиданные входные данные'),
  ErrorUnknownError.message: MessageLocalization(other: 'Неизвестная ошибка'),
};

```

Example of displayed localized error messages (in Russian):

```
"abc\u123xyz"
FormatException: line 1, column 10: Неожиданный символ 'x' (0x78)
"abc\u123xyz"
         ^

line 1, column 7: Ожидается 4-значное шестнадцатеричное число
"abc\u123xyz"
      ^^^
----------------------------------------
{"abc": `123}
FormatException: line 1, column 9: Ожидаются: '[', 'false', 'null', 'true', '{', 'строка', 'число'
{"abc": `123}
        ^
----------------------------------------
1.
FormatException: line 1, column 3: Неожиданный конец входных данных
1.
  ^

line 1, column 3: Ожидается: 'десятичная цифра'
1.
  ^
----------------------------------------

```

## Tracing

Tracing parsers is very easy. All you have to do is build a traceable parser.  
Building a traceable parser is also very easy.  

An example of how to build a traceable parser:

```dart
final builder = TracerBuilder(fastParse: fastParse, parse: parse);
final tracer = builder.build(parser);
```

Tracer is the same regular parser that will invoke the appropriate methods (`fastParse` and `parse`) of all traced parsers (that is, it will trace the entire parsing process).

An example of how to trace parsing:

```dart
Result<O>? parse<I, O>(Parser<I, O> parser, State<I> state) {
  stack.add(parser);
  if (bps.check(name: parser.name)) {
    print('breakpoint');
  }

  final result = parser.parse(state);
  stack.removeLast();
  return result;
}

```

A complete example of a simple parse trace:

```dart
void main(List<String> args) {
  final bps = Breakpoints();
  bps.add(name: 'fraction');
  bps.add(name: 'integer');
  final stack = <Object?>[];
  bool fastParse<I, O>(Parser<I, O> parser, State<I> state) {
    stack.add(parser);
    if (bps.check(name: parser.name)) {
      print('breakpoint');
    }

    final result = parser.fastParse(state);
    stack.removeLast();
    return result;
  }

  Result<O>? parse<I, O>(Parser<I, O> parser, State<I> state) {
    stack.add(parser);
    if (bps.check(name: parser.name)) {
      print('breakpoint');
    }

    final result = parser.parse(state);
    stack.removeLast();
    return result;
  }

  final builder = TracerBuilder(fastParse: fastParse, parse: parse);
  final tracer = builder.build(example.parser);
  final result = tracer.parseString('1.');
  print(result);
}

```

## Generating source code from code

It is possible to generate valid code from most parsers.  

An example of generated code.  

```dart
bool _tag2(State<StringReader> state) {
  const p = _i1.Tag.parseTag;
  const tag = 'false';
  return p(state, tag);
}

bool _terminated2(State<StringReader> state) {
  final pos = state.pos;
  final r1 = _tag2(state);
  if (r1) {
    final r2 = _ws(state);
    if (r2) {
      return true;
    }

    state.pos = pos;
  }

  return false;
}

Result<bool>? _false(State<StringReader> state) {
  const value = false;
  final r = _terminated2(state);
  if (r) {
    return Result(value);
  }

  return null;
}

```

An example of how the code can be generated can be found in the `tool` directory.
