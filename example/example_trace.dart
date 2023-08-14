import 'package:parser_combinator/extra/json_parser.dart' as json_parser;
import 'package:parser_combinator/parser_combinator.dart';
import 'package:parser_combinator/parsing.dart';
import 'package:parser_combinator/runtime.dart';
import 'package:parser_combinator/tracing.dart';

void main(List<String> args) {
  final bps = Breakpoints();
  bps.add(name: 'fraction');
  bps.add(name: 'integer');
  final stack = <Object?>[];
  bool fastParse<O>(Parser<StringReader, O> parser, State<StringReader> state) {
    stack.add(parser);
    if (bps.check(name: parser.name)) {
      print('breakpoint');
    }

    final result = parser.fastParse(state);
    stack.removeLast();
    return result;
  }

  Result<O>? parse<O>(
      Parser<StringReader, O> parser, State<StringReader> state) {
    stack.add(parser);
    if (bps.check(name: parser.name)) {
      print('breakpoint');
    }

    final result = parser.parse(state);
    stack.removeLast();
    return result;
  }

  final builder = TracerBuilder(fastParse: fastParse, parse: parse);
  final tracer = builder.build(json_parser.parser);
  final result = parseString(tracer.parse, '1.');
  print(result);
}
