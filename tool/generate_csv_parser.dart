import 'dart:async';

import 'package:parser_combinator/code_generator.dart';

import 'package:parser_combinator/extra/csv_parser.dart' as csv;

Future<void> main(List<String> args) async {
  //const filename = 'lib/extra/json_parser_generated.dart';
  const filename = 'tool/csv_parser_generated.dart';
  await generate(
    filename: filename,
    optimize: false,
    parsers: [csv.parser],
  );
}
