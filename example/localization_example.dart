import 'package:parser_combinator/extra/json_parser.dart' as json_parser;
import 'package:parser_combinator/parsing.dart';
import 'package:parser_combinator/runtime.dart';

void main(List<String> args) {
  parse(r'"abc\u123xyz"');
  parse('{"abc": `123}');
  parse('1.');
}

void parse(String text) {
  const parser = json_parser.parser;
  print(text);
  try {
    parseString(parser.parse, text, messages: _messages, tags: _tags);
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
  json_parser.ParserErrorMessages.expected4DigitHexadecimalNumber:
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
