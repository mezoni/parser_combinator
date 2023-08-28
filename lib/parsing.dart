import 'package:intl/intl.dart';

import 'runtime.dart';
import 'streaming.dart';

ParseResult<I, R> createParseResult<I, O, R>(
  State<I> state,
  R result,
  bool Function(R result) isSuccess, {
  String Function(I input, int offset, List<ErrorMessage> errors)? errorMessage,
  String? locale,
  Map<String, MessageLocalization> messages = const {},
  Map<String, String> tags = const {},
}) {
  final input = state.input;
  if (isSuccess(result)) {
    return ParseResult(
      failPos: state.failPos,
      input: input,
      pos: state.pos,
      result: result,
    );
  }

  final offset = state.failPos;
  final normalized = _normalize(input, offset, state.getErrors());
  final localized =
      _localize(input, offset, normalized, locale, messages, tags);
  String? message;
  if (errorMessage != null) {
    message = errorMessage(input, offset, localized);
  } else if (input is StringReader) {
    if (input.source != null) {
      message = _errorMessage(input.source!, offset, localized);
    } else {
      message = _errorMessage2(input, offset, localized);
    }
  } else if (input is String) {
    message = _errorMessage(input, offset, localized);
  } else {
    message = localized.join('\n');
  }

  return ParseResult(
    errors: localized,
    failPos: state.failPos,
    input: input,
    errorMessage: message,
    pos: state.pos,
    result: result,
  );
}

void fastParseString(
  bool Function(State<StringReader> state) fastParse,
  String source, {
  String Function(StringReader input, int offset, List<ErrorMessage> errors)?
      errorMessage,
  String? locale,
  Map<String, MessageLocalization> messages = const {},
  Map<String, String> tags = const {},
}) {
  final input = StringReader(source);
  final result = tryFastParse(
    fastParse,
    input,
    errorMessage: errorMessage,
    locale: locale,
    messages: messages,
    tags: tags,
  );

  if (result.result) {
    return;
  }

  errorMessage ??= errorMessage;
  final message = result.errorMessage;
  throw FormatException(message);
}

O parseInput<I, O>(
  Result<O>? Function(State<I> state) parse,
  I input, {
  String Function(I input, int offset, List<ErrorMessage> errors)? errorMessage,
  String? locale,
  Map<String, MessageLocalization> messages = const {},
  Map<String, String> tags = const {},
}) {
  final result = tryParse(
    parse,
    input,
    errorMessage: errorMessage,
    locale: locale,
    messages: messages,
    tags: tags,
  );

  return result.value;
}

O parseString<O>(
  Result<O>? Function(State<StringReader> state) parse,
  String source, {
  String Function(StringReader input, int offset, List<ErrorMessage> errors)?
      errorMessage,
  String? locale,
  Map<String, MessageLocalization> messages = const {},
  Map<String, String> tags = const {},
}) {
  final input = StringReader(source);
  final result = tryParse(
    parse,
    input,
    errorMessage: errorMessage,
    locale: locale,
    messages: messages,
    tags: tags,
  );

  return result.value;
}

ParseResult<I, bool> tryFastParse<I>(
  bool Function(State<I> state) fastParse,
  I input, {
  String Function(I input, int offset, List<ErrorMessage> errors)? errorMessage,
  String? locale,
  Map<String, MessageLocalization> messages = const {},
  Map<String, String> tags = const {},
}) {
  final result = _parse<I, bool, bool>(
    fastParse,
    (result) => result,
    input,
    errorMessage: errorMessage,
    locale: locale,
    messages: messages,
    tags: tags,
  );
  return result;
}

ParseResult<I, Result<O>?> tryParse<I, O>(
  Result<O>? Function(State<I> state) parse,
  I input, {
  String Function(I input, int offset, List<ErrorMessage> errors)? errorMessage,
  String? locale,
  Map<String, MessageLocalization> messages = const {},
  Map<String, String> tags = const {},
}) {
  final result = _parse<I, O, Result<O>?>(
    parse,
    (result) => result != null,
    input,
    errorMessage: errorMessage,
    locale: locale,
    messages: messages,
    tags: tags,
  );
  return result;
}

String _errorMessage(String input, int offset, List<ErrorMessage> errors) {
  final sb = StringBuffer();
  final errorInfoList = errors
      .map((e) => (length: e.length, message: e.toString()))
      .toSet()
      .toList();
  for (var i = 0; i < errorInfoList.length; i++) {
    int max(int x, int y) => x > y ? x : y;
    int min(int x, int y) => x < y ? x : y;
    if (sb.isNotEmpty) {
      sb.writeln();
      sb.writeln();
    }

    final errorInfo = errorInfoList[i];
    final length = errorInfo.length;
    final message = errorInfo.message;
    final start = min(offset + length, offset);
    final end = max(offset + length, offset);
    var row = 1;
    var lineStart = 0, next = 0, pos = 0;
    while (pos < input.length) {
      final c = input.codeUnitAt(pos++);
      if (c == 0xa || c == 0xd) {
        next = c == 0xa ? 0xd : 0xa;
        if (pos < input.length && input.codeUnitAt(pos) == next) {
          pos++;
        }
        if (pos - 1 >= start) {
          break;
        }
        row++;
        lineStart = pos;
      }
    }

    final inputLen = input.length;
    final lineLimit = min(80, inputLen);
    final start2 = start;
    final end2 = min(start2 + lineLimit, end);
    final errorLen = end2 - start;
    final extraLen = lineLimit - errorLen;
    final rightLen = min(inputLen - end2, extraLen - (extraLen >> 1));
    final leftLen = min(start, max(0, lineLimit - errorLen - rightLen));
    var index = start2 - 1;
    final list = <int>[];
    for (var i = 0; i < leftLen && index >= 0; i++) {
      var cc = input.codeUnitAt(index--);
      if ((cc & 0xFC00) == 0xDC00 && (index > 0)) {
        final pc = input.codeUnitAt(index);
        if ((pc & 0xFC00) == 0xD800) {
          cc = 0x10000 + ((pc & 0x3FF) << 10) + (cc & 0x3FF);
          index--;
        }
      }

      list.add(cc);
    }

    final column = start - lineStart + 1;
    final left = String.fromCharCodes(list.reversed);
    final end3 = min(inputLen, start2 + (lineLimit - leftLen));
    final indicatorLen = max(1, errorLen);
    final right = input.substring(start2, end3);
    var text = left + right;
    text = text.replaceAll('\n', ' ');
    text = text.replaceAll('\r', ' ');
    text = text.replaceAll('\t', ' ');
    sb.writeln('line $row, column $column: $message');
    sb.writeln(text);
    sb.write(' ' * leftLen + '^' * indicatorLen);
  }

  return sb.toString();
}

String _errorMessage2(
    StringReader input, int offset, List<ErrorMessage> errors) {
  final sb = StringBuffer();
  final errorInfoList = errors
      .map((e) => (length: e.length, message: e.toString()))
      .toSet()
      .toList();
  for (var i = 0; i < errorInfoList.length; i++) {
    int max(int x, int y) => x > y ? x : y;
    int min(int x, int y) => x < y ? x : y;
    if (sb.isNotEmpty) {
      sb.writeln();
      sb.writeln();
    }

    final errorInfo = errorInfoList[i];
    final length = errorInfo.length;
    final message = errorInfo.message;
    final start = min(offset + length, offset);
    final end = max(offset + length, offset);
    final inputLen = input.length;
    final lineLimit = min(80, inputLen);
    final start2 = start;
    final end2 = min(start2 + lineLimit, end);
    final errorLen = end2 - start;
    final indicatorLen = max(1, errorLen);
    var text = input.substring(start, lineLimit);
    text = text.replaceAll('\n', ' ');
    text = text.replaceAll('\r', ' ');
    text = text.replaceAll('\t', ' ');
    sb.writeln('offset $offset: $message');
    sb.writeln(text);
    sb.write('^' * indicatorLen);
  }

  return sb.toString();
}

List<ErrorMessage> _localize<I>(
  I input,
  int offset,
  List<ParseError> errors,
  String? locale,
  Map<String, MessageLocalization> messages,
  Map<String, String> tags,
) {
  final result = <ErrorMessage>[];
  for (var i = 0; i < errors.length; i++) {
    final element = errors[i];
    var message = element.getErrorMessage(input, offset);
    var text = message.text;
    final localization = messages[text] ?? MessageLocalization(other: text);
    if (element case final ErrorExpectedTags element2) {
      final elementTags = element2.tags;
      text = Intl.plural(
        elementTags.length,
        other: localization.other,
        zero: localization.zero,
        one: localization.one,
        two: localization.two,
        few: localization.few,
        many: localization.many,
        locale: locale,
      );
      final newTags = element2.tags.map((e) => tags[e] ?? e).toList();
      message = ErrorExpectedTags(newTags).getErrorMessage(input, offset);
      message = ErrorMessage(message.length, text, message.arguments);
    } else {
      final arguments = message.arguments;
      num howMany = 0;
      for (var i = 0; i < arguments.length; i++) {
        final argument = arguments[i];
        if (argument is num) {
          howMany = argument;
          break;
        }
      }

      text = Intl.plural(
        howMany,
        other: localization.other,
        zero: localization.zero,
        one: localization.one,
        two: localization.two,
        few: localization.few,
        many: localization.many,
        locale: locale,
      );
      message = ErrorMessage(message.length, text, arguments);
    }

    result.add(message);
  }

  return result;
}

List<ParseError> _normalize<I>(I input, int offset, List<ParseError> errors) {
  final result = errors.toList();
  if (input case final StringReader input) {
    if (offset >= input.length) {
      result.add(const ErrorUnexpectedEndOfInput());
      result.removeWhere((e) => e is ErrorUnexpectedCharacter);
    }
  } else if (input case final ChunkedData<StringReader> input) {
    if (input.isClosed && offset == input.start + input.data.length) {
      result.add(const ErrorUnexpectedEndOfInput());
      result.removeWhere((e) => e is ErrorUnexpectedCharacter);
    }
  }

  final foundTags =
      result.whereType<ErrorExpectedTag>().map((e) => e.tag).toList();
  if (foundTags.isNotEmpty) {
    result.removeWhere((e) => e is ErrorExpectedTag);
    result.add(ErrorExpectedTags(foundTags));
  }

  final expectedTags = result.whereType<ErrorExpectedTags>().toList();
  if (expectedTags.isNotEmpty) {
    result.removeWhere((e) => e is ErrorExpectedTags);
    final tags = <String>{};
    for (final error in expectedTags) {
      tags.addAll(error.tags);
    }

    final tagList = tags.toList();
    tagList.sort();
    final error = ErrorExpectedTags(tagList);
    result.add(error);
  }

  return result;
}

ParseResult<I, R> _parse<I, O, R>(
  R Function(State<I> input) parse,
  bool Function(R result) isSuccess,
  I input, {
  String Function(I input, int offset, List<ErrorMessage> errors)? errorMessage,
  String? locale,
  Map<String, MessageLocalization> messages = const {},
  Map<String, String> tags = const {},
}) {
  final state = State(input);
  final result = parse(state);
  return createParseResult<I, O, R>(state, result, isSuccess,
      errorMessage: errorMessage,
      locale: locale,
      messages: messages,
      tags: tags);
}

class MessageLocalization {
  final String? zero;

  final String? one;

  final String? two;

  final String? few;

  final String? many;

  final String other;

  const MessageLocalization({
    this.zero,
    this.one,
    this.two,
    this.few,
    this.many,
    required this.other,
  });
}

class ParseResult<I, O> {
  final String errorMessage;

  final List<ErrorMessage> errors;

  final int failPos;

  final I input;

  final int pos;

  final O result;

  ParseResult({
    this.errorMessage = '',
    this.errors = const [],
    required this.failPos,
    required this.input,
    required this.pos,
    required this.result,
  });
}

extension ParseResultParseExt<I, O> on ParseResult<I, Result<O>?> {
  O get value {
    if (result != null) {
      return result!.value;
    }

    throw FormatException('\n$errorMessage');
  }
}
