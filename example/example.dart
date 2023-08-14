import 'package:parser_combinator/parser/chainl1.dart';
import 'package:parser_combinator/parser/choice.dart';
import 'package:parser_combinator/parser/delimited.dart';
import 'package:parser_combinator/parser/digit1.dart';
import 'package:parser_combinator/parser/map.dart';
import 'package:parser_combinator/parser/opt.dart';
import 'package:parser_combinator/parser/predicate.dart';
import 'package:parser_combinator/parser/recognize.dart';
import 'package:parser_combinator/parser/ref.dart';
import 'package:parser_combinator/parser/satisfy.dart';
import 'package:parser_combinator/parser/skip_while.dart';
import 'package:parser_combinator/parser/tag.dart';
import 'package:parser_combinator/parser/tags.dart';
import 'package:parser_combinator/parser/terminated.dart';
import 'package:parser_combinator/parser_combinator.dart';
import 'package:parser_combinator/parsing.dart';
import 'package:parser_combinator/string_reader.dart';

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
