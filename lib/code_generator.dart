// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:_fe_analyzer_shared/src/parser/listener.dart';
import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as parser_impl;
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart';
import 'package:path/path.dart' as path;

import 'parser/predicate.dart';
import 'parser/ref.dart';
import 'parser_combinator.dart';

Future<void> generate({
  Allocator? allocator,
  List<Convert> converters = const [],
  required String filename,
  bool optimize = false,
  required List<Parser<Object?, Object?>> parsers,
  String prefix = '_',
}) async {
  allocator ??= Allocator(prefix);
  final g = CodeGenerator(Allocator(prefix));
  final source = g.generate(
    filename: filename,
    optimize: optimize,
    parsers: parsers,
  );
  File(filename).writeAsStringSync(source);
  final process =
      await Process.start(Platform.executable, ['format', filename]);
  unawaited(process.stdout.transform(utf8.decoder).forEach(print));
  unawaited(process.stderr.transform(utf8.decoder).forEach(print));
}

typedef Convert = CodeInfo Function(Object? object);

typedef _Parser = Parser<Object?, Object?>;

class Allocator {
  final Set<String> _inUse = {};

  final Map<String, int> _names = {};

  final String prefix;

  Allocator(this.prefix);

  String allocate([String name = '']) {
    var id = _names[name];
    id ??= 0;
    var id2 = id;
    var result = '';
    final endsWithDigit =
        name.isNotEmpty && isDigit(name.codeUnitAt(name.length - 1));
    while (true) {
      result = endsWithDigit ? '$prefix${name}_$id' : '$prefix$name$id';
      if (_inUse.add(result)) {
        break;
      }

      id2++;
    }

    _names[name] = id2 + 1;
    return result;
  }
}

class CodeGenerator {
  final Allocator allocator;

  StringBuffer _buffer = StringBuffer();

  final List<Convert> _converters = [];

  final Map<Uri, String> _imports = {};

  // ignore: unused_field
  bool _optimize = false;

  final Map<({bool isFast, _Parser parser}), String> _parsers = {};

  CodeGenerator(this.allocator);

  String generate({
    List<Convert> converters = const [],
    required String filename,
    bool optimize = false,
    required List<Parser<Object?, Object?>> parsers,
  }) {
    _buffer = StringBuffer();
    _optimize = optimize;
    _converters.clear();
    _converters.addAll(_converters);
    _converters.add(_objectToCode);
    for (var i = 0; i < parsers.length; i++) {
      final parser = parsers[i];
      if (parser.name == null) {
        throw ArgumentError.value(parser, 'parsers[$i]', 'Must have a name');
      }

      _generate(parser, false);
    }

    final imports = _generateImports(filename);
    final buffer = StringBuffer();
    buffer.write(imports);
    buffer.writeln(_buffer);
    return buffer.toString();
  }

  String _addImport(Uri uri) {
    if ('$uri' == 'dart:core') {
      return '';
    }

    var result = _imports[uri];
    if (result != null) {
      return result;
    }

    result = _allocate('i');
    _imports[uri] = result;
    return result;
  }

  String _addPrefix(String prefix, String name) {
    if (prefix.isEmpty) {
      return name;
    }

    return '$prefix.$name';
  }

  String _allocate(String key) {
    return allocator.allocate(key);
  }

  void _checkValidName(_Parser parser, String name) {
    const reserved = {
      'Map',
      'Object',
      'String',
      'assert',
      'break',
      'catch',
      'class',
      'const',
      'continue',
      'default',
      'do',
      'else',
      'enum',
      'extends',
      'false',
      'final',
      'finally',
      'for',
      'if',
      'in',
      'is',
      'new',
      'null',
      'rethrow',
      'return',
      'switch',
      'super',
      'this',
      'true',
      'try',
      'var',
      'void',
      'when',
      'while',
      'with',
    };
    if (name.isEmpty) {
      _error(parser, "Parser name must not be empty");
    }

    if (reserved.contains(name)) {
      _error(parser, "Parser name must not use reserved word '$name'");
    }

    final c = name.codeUnitAt(0);
    if (!(isAlpha(c) || c == 0x5f || c == 0x24) ||
        name.codeUnits
            .skip(1)
            .any((e) => !(isAlphanumeric(e) || e == 0x5f || c == 0x24))) {
      _error(parser, "Invalid parser name '$name'");
    }
  }

  Never _error(Object? object, String message) {
    throw StateError('$message, ${object.runtimeType} $object');
  }

  CodeInfo _functionToCode(Function object) {
    final instance = reflect(object);
    if (instance is ClosureMirror) {
      final function = instance.function;
      final name = _symbolToString(function.simpleName);
      if (function.isTopLevel) {
        if (function.isPrivate) {
          return CodeInfo(
              isConst: false,
              message: "External private functions'$name' are not supported");
        }

        final owner = function.owner;
        if (owner is! LibraryMirror) {
          return CodeInfo(
              isConst: false,
              message:
                  "The owner of the top-level function '$name is not a library");
        }

        final prefix = _addImport(owner.uri);
        final code = _addPrefix(prefix, name);
        return CodeInfo(isConst: true, code: code);
      } else if (function.isStatic) {
        final owner = function.owner;
        if (owner is ClassMirror) {
          final classOwner = owner.owner;
          if (classOwner is! LibraryMirror) {
            return CodeInfo(
                isConst: false,
                message:
                    "The owner '$classOwner' of the class is not a library");
          }

          if (function.isConstructor) {
            final prefix = _addImport(classOwner.uri);
            final code = _addPrefix(prefix, name);
            return CodeInfo(isConst: true, code: code);
          } else {
            final className = _symbolToString(owner.simpleName);
            final prefix = _addImport(classOwner.uri);
            final code = _addPrefix(prefix, '$className.$name');
            return CodeInfo(isConst: true, code: code);
          }
        } else {
          var source = function.source;
          if (source == null || source.isEmpty) {
            return CodeInfo(
                isConst: false,
                message:
                    "The source code of the function $object is not available");
          }

          source = source.trim();
          if (source.startsWith('(')) {
            final returnType = function.returnType;
            final library = _getTypeOwner(returnType);
            final prefix = library != null ? _addImport(library.uri) : '';
            final returnTypeName =
                _addPrefix(prefix, _symbolToString(returnType.simpleName));
            final isExpressionFunction = !source.endsWith('}');
            source = isExpressionFunction ? '$source;' : source;
            source = '$returnTypeName $name $source';
            return CodeInfo(isConst: false, code: source);
          } else {
            return CodeInfo(isConst: false, code: source);
          }
        }
      } else {
        final functionOwner = function.owner;
        if (functionOwner is ClassMirror) {
          final functionName = _symbolToString(function.simpleName);
          final type = _symbolToString(functionOwner.simpleName);
          return CodeInfo(
              isConst: false,
              message:
                  "Class instance method '$type.$functionName' are not supported");
        }

        return CodeInfo(
            isConst: false,
            message: "Non static method '$object' are not supported");
      }
    }

    return CodeInfo(isConst: false, message: 'Unknown function $object');
  }

  String _generate(_Parser parser, bool isFast) {
    if (parser is Ref) {
      parser = parser.f();
    }

    final parserKey = (isFast: isFast, parser: parser);
    var parseFunctionName = _parsers[parserKey];
    if (parseFunctionName != null) {
      return parseFunctionName;
    }

    final parserInstance = reflect(parser);
    final parserType = parserInstance.type;
    final parserObject = parserInstance.reflectee;
    parseFunctionName = _getParserName(parser);
    _parsers[parserKey] = parseFunctionName;
    final parserMembers = parserType.declarations;
    final methods = parserMembers.values.whereType<MethodMirror>();
    final parseMethodName = isFast ? 'fastParse' : 'parse';
    final parseMethodSymbol = Symbol(parseMethodName);
    final parseMethod =
        methods.where((e) => e.simpleName == parseMethodSymbol).firstOrNull;
    if (parseMethod == null) {
      _error(parserObject, "Class method '$parseMethodName' was not fount");
    }

    var functionCode = parseMethod.source;
    if (functionCode == null) {
      _error(parserObject,
          "Source code is not available for class method '$parseMethodName'");
    }

    functionCode = functionCode.replaceAll('@override', '').trim();
    final scanResult = scanString(functionCode);
    final listener = _Listener();
    final parserImpl = parser_impl.Parser(listener);
    parserImpl.parseUnit(scanResult.tokens);
    if (listener._isExpressionFunction) {
      _error(parserObject,
          "Parsing methods as function expressions are not currently supported '$parseMethodName'");
    }

    final beginBlock = listener._beginBlock;
    if (beginBlock == null) {
      _error(parserObject,
          "Parsing methods without a body are not supported '$parseMethodName'");
    }

    var bodyCode = functionCode.substring(beginBlock.offset);
    final methodParse =
        methods.where((e) => e.simpleName == #parse).firstOrNull;
    if (methodParse == null) {
      _error(parserObject, "Method 'parse' not found");
    }

    final parameters = methodParse.parameters;
    if (parameters.length != 1) {
      _error(parserObject, "Invalid number of parameters for method 'parse'");
    }

    final parameter = parameters[0];
    if (parameter.isNamed || parameter.isOptional) {
      _error(parserObject, "Invalid parameters for method 'parse'");
    }

    final stateName = _symbolToString(parameter.simpleName);
    final stateType = parameter.type.reflectedType;
    final fields = parserMembers.values.whereType<VariableMirror>();
    final fieldsWithParsers = <String, _Parser>{};
    for (final field in fields) {
      final fieldInstance = parserInstance.getField(field.simpleName);
      final fieldObject = fieldInstance.reflectee;
      if (fieldObject is _Parser) {
        final fieldName = _symbolToString(field.simpleName);
        fieldsWithParsers[fieldName] = fieldObject;
      }
    }

    bodyCode = _generateParsers(stateName, bodyCode, fieldsWithParsers);
    final variables = <String, CodeInfo>{};
    final localFunctions = <String>[];
    for (final field in fields) {
      final fieldName = _symbolToString(field.simpleName);
      final fieldInstance = parserInstance.getField(field.simpleName);
      final fieldObject = fieldInstance.reflectee;
      if (fieldObject is! _Parser) {
        var done = false;
        for (final converter in _converters) {
          final codeInfo = converter(fieldObject);
          if (codeInfo.code != null) {
            variables[fieldName] = codeInfo;
            done = true;
            break;
          }
        }

        if (!done) {
          _error(
              parserObject, "Unable to convert object '$fieldObject' to code");
        }
      }
    }

    final buffer = StringBuffer();
    final resultType = parserObject.getOutputType;
    if (isFast) {
      buffer.write('bool ');
    } else {
      buffer.write('Result<$resultType>? ');
    }

    buffer.write(parseFunctionName);
    buffer.write('($stateType $stateName)');
    buffer.writeln('{');
    for (final element in localFunctions) {
      final code = element;
      buffer.writeln(code);
    }

    for (final element in variables.entries.where((e) => e.value.isConst)) {
      final key = element.key;
      final code = element.value.code;
      buffer.writeln('const $key = $code;');
    }

    for (final element in variables.entries.where((e) => !e.value.isConst)) {
      final key = element.key;
      final code = element.value.code;
      buffer.writeln('final $key = $code;');
    }

    buffer.writeln(bodyCode.substring(1).trim());
    final source = buffer.toString();
    // TODO: Optimize parser code
    //source = _optimizeParserCode(parser, source);
    _buffer.writeln(source);
    return parseFunctionName;
  }

  String _generateImports(String filename) {
    final currentPath = path.dirname(path.absolute(filename));
    final dartImports = <String>[];
    final packageImports = <String>[];
    final fileImports = <String>[];
    packageImports.add("import 'package:parser_combinator/runtime.dart';");
    for (final element in _imports.entries) {
      var uri = element.key;
      final prefix = element.value;
      final scheme = uri.scheme;
      List<String>? dest;
      if (scheme == 'dart') {
        dest = dartImports;
      } else if (scheme == 'package') {
        dest = packageImports;
      } else if (scheme == 'file') {
        var filepath = uri.toFilePath(windows: Platform.isWindows);
        filepath = path.relative(filepath, from: currentPath);
        uri = Uri.parse(filepath);
        dest = fileImports;
      } else {
        throw StateError('Unsupported import URI scheme : $uri');
      }

      dest.add("import '$uri' as $prefix;");
    }

    final buffer = StringBuffer();
    final groups = [dartImports, packageImports, fileImports];
    if (allocator.prefix.startsWith('_') && _imports.isNotEmpty) {
      buffer.writeln(
          '// ignore_for_file: no_leading_underscores_for_library_prefixes');
    }

    for (final group in groups) {
      if (group.isNotEmpty) {
        group.sort();
        buffer.writeln(group.join('\n'));
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  String? _generateParserInvocation({
    required String bodyCode,
    required String fieldName,
    required bool isFast,
    required _Parser parser,
    required String stateName,
  }) {
    // TODO:
    return null;
  }

  String _generateParsers(
      String stateName, String bodyCode, Map<String, _Parser> parsers) {
    var fieldNames = parsers.keys.toList();
    fieldNames.sort();
    fieldNames = fieldNames.reversed.toList();
    for (final fieldName in fieldNames) {
      for (final methodName in const ['fastParse', 'parse']) {
        final key = '$fieldName.$methodName';
        if (!bodyCode.contains(key)) {
          continue;
        }

        final isFast = methodName == 'fastParse' ? true : false;
        final parser = parsers[fieldName]!;
        final code = _generateParserInvocation(
            bodyCode: bodyCode,
            fieldName: fieldName,
            isFast: isFast,
            parser: parser,
            stateName: stateName);
        if (code != null) {
          bodyCode = code;
        } else {
          final functionName = _generate(parser, isFast);
          bodyCode = bodyCode.replaceAll(key, functionName);
        }
      }
    }

    return bodyCode;
  }

  String _getParserName(_Parser parser) {
    if (parser.name != null) {
      final name = parser.name!;
      _checkValidName(parser, name);
      return name;
    } else {
      var name = '${parser.runtimeType}';
      final index = name.indexOf('<');
      if (index != -1) {
        name = name.substring(0, index);
      }

      name = name[0].toLowerCase() + name.substring(1);
      return _allocate(name);
    }
  }

  LibraryMirror? _getTypeOwner(TypeMirror type) {
    final owner = type.owner;
    if (owner is LibraryMirror) {
      return owner;
    }

    return null;
  }

  CodeInfo _objectToCode(Object? object) {
    if (object == null) {
      return CodeInfo(isConst: true, code: 'null');
    } else if (object is String) {
      return CodeInfo(isConst: true, code: CodeGenerator.escapeString(object));
    } else if (object is num) {
      return CodeInfo(isConst: true, code: '$object');
    } else if (object is bool) {
      return CodeInfo(isConst: true, code: '$object');
    } else if (object is List) {
      final elements = <String>[];
      var isConst = true;
      for (final element in object) {
        final record = _objectToCode(element);
        if (record.code == null) {
          return record;
        }

        if (!record.isConst) {
          isConst = false;
        }

        elements.add(record.code!);
      }

      return CodeInfo(isConst: isConst, code: '[${elements.join(', ')}]');
    } else if (object is Set) {
      final elements = <String>[];
      var isConst = true;
      for (final element in object) {
        final record = _objectToCode(element);
        if (record.code == null) {
          return record;
        }

        if (!record.isConst) {
          isConst = false;
        }

        elements.add(record.code!);
      }

      return CodeInfo(isConst: isConst, code: '{${elements.join(', ')}}');
    } else if (object is Map) {
      final entries = <String>[];
      var isConst = true;
      for (final element in object.entries) {
        final key = _objectToCode(element.key);
        final value = _objectToCode(element.value);
        if (key.code == null) {
          return value;
        }

        if (value.code == null) {
          return value;
        }

        if (!key.isConst) {
          isConst = false;
        }

        if (!value.isConst) {
          isConst = false;
        }

        entries.add('${key.code!}: ${value.code!}');
      }

      return CodeInfo(isConst: isConst, code: '{${entries.join(', ')}}');
    } else if (object is Function) {
      return _functionToCode(object);
    }

    return CodeInfo(
        isConst: false,
        message:
            "Unable to convert object '${object.runtimeType}' to code expression");
  }

  String _symbolToString(Symbol symbol) {
    var result = symbol.toString();
    result = result.substring(8, result.length - 2);
    return result;
  }

  static String escapeString(String text, [bool quote = true]) {
    text = text.replaceAll('\\', r'\\');
    text = text.replaceAll('\b', r'\b');
    text = text.replaceAll('\f', r'\f');
    text = text.replaceAll('\n', r'\n');
    text = text.replaceAll('\r', r'\r');
    text = text.replaceAll('\t', r'\t');
    text = text.replaceAll('\v', r'\v');
    text = text.replaceAll('\'', '\\\'');
    text = text.replaceAll('\$', r'\$');
    if (!quote) {
      return text;
    }

    return '\'$text\'';
  }
}

class CodeInfo {
  final bool isConst;

  final String? code;

  final String? message;

  CodeInfo({
    required this.isConst,
    this.code,
    this.message,
  });
}

class _Listener extends Listener {
  Token? _beginBlock;

  int _bodyLevel = 0;

  bool _isExpressionFunction = false;

  @override
  void beginBlockFunctionBody(Token token) {
    _bodyLevel++;
    super.beginBlockFunctionBody(token);
  }

  @override
  void endBlockFunctionBody(int count, Token beginToken, Token endToken) {
    super.endBlockFunctionBody(count, beginToken, endToken);
    _bodyLevel--;
    if (_bodyLevel == 0) {
      _beginBlock = beginToken;
    }
  }

  @override
  void handleExpressionFunctionBody(Token arrowToken, Token? endToken) {
    super.handleExpressionFunctionBody(arrowToken, endToken);
    if (_bodyLevel == 0) {
      _isExpressionFunction = true;
    }
  }
}
