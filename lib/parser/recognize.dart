import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

/// Stores the current parsing position and invokes invokes the [p] parser.
///
/// Parsing succeeds if parsing by the [p] parser succeeds.
///
/// Otherwise, parsing fails.
///
/// Returns: Input string value from the stored position to the last parsed
/// position.
class Recognize<O> extends Parser<StringReader, String> {
  final Parser<StringReader, O> p;

  const Recognize(this.p, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Recognize(name: name, builder.build(p));
  }

  @override
  bool fastParse(State<StringReader> state) {
    return p.fastParse(state);
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final pos = state.pos;
    final r = p.fastParse(state);
    if (r) {
      return state.pos != pos
          ? Result(state.input.substring(pos, state.pos))
          : Result('');
    }

    return null;
  }

  @override
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<String>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O> r1;
    var action = 0;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = p.parseAsync(state);
            action = 1;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 1:
            if ((result.ok = r1.ok) == false) {
              state.pos = pos;
            } else {
              result.value =
                  Result(input.data.source.substring(pos, state.pos));
            }

            input.handler = result.handler;
            action = -1;
            return;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}

/// Stores the current parsing position and invokes all specified parsers.
///
/// Parsing succeeds if the parsing of all parsers succeeds.
///
/// Otherwise, parsing fails.
///
/// Returns: Input string value from the stored position to the last parsed
/// position.
class Recognize2<O1, O2> extends Parser<StringReader, String> {
  final Parser<StringReader, O1> p1;

  final Parser<StringReader, O2> p2;

  const Recognize2(this.p1, this.p2, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Recognize2(name: name, builder.build(p1), builder.build(p2));
  }

  @override
  bool fastParse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = p2.fastParse(state);
      if (r2) {
        return true;
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        return state.pos != pos
            ? Result(state.input.substring(pos, state.pos))
            : const Result('');
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<String>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O1> r1;
    late AsyncResult<O2> r2;
    var action = 0;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = p1.parseAsync(state);
            action = 1;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 1:
            if (r1.ok == false) {
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r2 = p2.parseAsync(state);
            action = 2;
            if (r2.ok == null) {
              r2.handler = parse;
              return;
            }

            break;
          case 2:
            if ((result.ok = r2.ok) == false) {
              state.pos = pos;
            } else {
              result.value =
                  Result(input.data.source.substring(pos, state.pos));
            }

            input.handler = result.handler;
            action = -1;
            return;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}

/// Stores the current parsing position and invokes all specified parsers.
///
/// Parsing succeeds if the parsing of all parsers succeeds.
///
/// Otherwise, parsing fails.
///
/// Returns: Input string value from the stored position to the last parsed
/// position.
/// Stores the current parsing position and invokes all specified parsers.
///
/// Parsing succeeds if the parsing of all parsers succeeds.
///
/// Otherwise, parsing fails.
///
/// Returns: Input string value from the stored position to the last parsed
/// position.
class Recognize3<O1, O2, O3> extends Parser<StringReader, String> {
  final Parser<StringReader, O1> p1;

  final Parser<StringReader, O2> p2;

  final Parser<StringReader, O3> p3;

  const Recognize3(this.p1, this.p2, this.p3, {String? name}) : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Recognize3(
        name: name, builder.build(p1), builder.build(p2), builder.build(p3));
  }

  @override
  bool fastParse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = p2.fastParse(state);
      if (r2) {
        final r3 = p3.fastParse(state);
        if (r3) {
          return true;
        }
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        final r3 = p3.parse(state);
        if (r3 != null) {
          return state.pos != pos
              ? Result(state.input.substring(pos, state.pos))
              : const Result('');
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<String>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O1> r1;
    late AsyncResult<O2> r2;
    late AsyncResult<O3> r3;
    var action = 0;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = p1.parseAsync(state);
            action = 1;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 1:
            if (r1.ok == false) {
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r2 = p2.parseAsync(state);
            action = 2;
            if (r2.ok == null) {
              r2.handler = parse;
              return;
            }

            break;
          case 2:
            if (r2.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r3 = p3.parseAsync(state);
            action = 3;
            if (r3.ok == null) {
              r3.handler = parse;
              return;
            }

            break;
          case 3:
            if ((result.ok = r3.ok) == false) {
              state.pos = pos;
            } else {
              result.value =
                  Result(input.data.source.substring(pos, state.pos));
            }

            input.handler = result.handler;
            action = -1;
            return;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}

/// Stores the current parsing position and invokes all specified parsers.
///
/// Parsing succeeds if the parsing of all parsers succeeds.
///
/// Otherwise, parsing fails.
///
/// Returns: Input string value from the stored position to the last parsed
/// position.
class Recognize4<O1, O2, O3, O4> extends Parser<StringReader, String> {
  final Parser<StringReader, O1> p1;

  final Parser<StringReader, O2> p2;

  final Parser<StringReader, O3> p3;

  final Parser<StringReader, O4> p4;

  const Recognize4(this.p1, this.p2, this.p3, this.p4, {String? name})
      : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Recognize4(
        name: name,
        builder.build(p1),
        builder.build(p2),
        builder.build(p3),
        builder.build(p4));
  }

  @override
  bool fastParse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = p2.fastParse(state);
      if (r2) {
        final r3 = p3.fastParse(state);
        if (r3) {
          final r4 = p4.fastParse(state);
          if (r4) {
            return true;
          }
        }
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        final r3 = p3.parse(state);
        if (r3 != null) {
          final r4 = p4.parse(state);
          if (r4 != null) {
            return state.pos != pos
                ? Result(state.input.substring(pos, state.pos))
                : const Result('');
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<String>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O1> r1;
    late AsyncResult<O2> r2;
    late AsyncResult<O3> r3;
    late AsyncResult<O4> r4;
    var action = 0;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = p1.parseAsync(state);
            action = 1;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 1:
            if (r1.ok == false) {
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r2 = p2.parseAsync(state);
            action = 2;
            if (r2.ok == null) {
              r2.handler = parse;
              return;
            }

            break;
          case 2:
            if (r2.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r3 = p3.parseAsync(state);
            action = 3;
            if (r3.ok == null) {
              r3.handler = parse;
              return;
            }

            break;
          case 3:
            if (r3.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r4 = p4.parseAsync(state);
            action = 4;
            if (r4.ok == null) {
              r4.handler = parse;
              return;
            }

            break;
          case 4:
            if ((result.ok = r4.ok) == false) {
              state.pos = pos;
            } else {
              result.value =
                  Result(input.data.source.substring(pos, state.pos));
            }

            input.handler = result.handler;
            action = -1;
            return;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}

/// Stores the current parsing position and invokes all specified parsers.
///
/// Parsing succeeds if the parsing of all parsers succeeds.
///
/// Otherwise, parsing fails.
///
/// Returns: Input string value from the stored position to the last parsed
/// position.
class Recognize5<O1, O2, O3, O4, O5> extends Parser<StringReader, String> {
  final Parser<StringReader, O1> p1;

  final Parser<StringReader, O2> p2;

  final Parser<StringReader, O3> p3;

  final Parser<StringReader, O4> p4;

  final Parser<StringReader, O5> p5;

  const Recognize5(this.p1, this.p2, this.p3, this.p4, this.p5, {String? name})
      : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Recognize5(
        name: name,
        builder.build(p1),
        builder.build(p2),
        builder.build(p3),
        builder.build(p4),
        builder.build(p5));
  }

  @override
  bool fastParse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = p2.fastParse(state);
      if (r2) {
        final r3 = p3.fastParse(state);
        if (r3) {
          final r4 = p4.fastParse(state);
          if (r4) {
            final r5 = p5.fastParse(state);
            if (r5) {
              return true;
            }
          }
        }
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        final r3 = p3.parse(state);
        if (r3 != null) {
          final r4 = p4.parse(state);
          if (r4 != null) {
            final r5 = p5.parse(state);
            if (r5 != null) {
              return state.pos != pos
                  ? Result(state.input.substring(pos, state.pos))
                  : const Result('');
            }
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<String>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O1> r1;
    late AsyncResult<O2> r2;
    late AsyncResult<O3> r3;
    late AsyncResult<O4> r4;
    late AsyncResult<O5> r5;
    var action = 0;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = p1.parseAsync(state);
            action = 1;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 1:
            if (r1.ok == false) {
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r2 = p2.parseAsync(state);
            action = 2;
            if (r2.ok == null) {
              r2.handler = parse;
              return;
            }

            break;
          case 2:
            if (r2.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r3 = p3.parseAsync(state);
            action = 3;
            if (r3.ok == null) {
              r3.handler = parse;
              return;
            }

            break;
          case 3:
            if (r3.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r4 = p4.parseAsync(state);
            action = 4;
            if (r4.ok == null) {
              r4.handler = parse;
              return;
            }

            break;
          case 4:
            if (r4.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r5 = p5.parseAsync(state);
            action = 5;
            if (r5.ok == null) {
              r5.handler = parse;
              return;
            }

            break;
          case 5:
            if ((result.ok = r5.ok) == false) {
              state.pos = pos;
            } else {
              result.value =
                  Result(input.data.source.substring(pos, state.pos));
            }

            input.handler = result.handler;
            action = -1;
            return;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}

/// Stores the current parsing position and invokes all specified parsers.
///
/// Parsing succeeds if the parsing of all parsers succeeds.
///
/// Otherwise, parsing fails.
///
/// Returns: Input string value from the stored position to the last parsed
/// position.
class Recognize6<O1, O2, O3, O4, O5, O6> extends Parser<StringReader, String> {
  final Parser<StringReader, O1> p1;

  final Parser<StringReader, O2> p2;

  final Parser<StringReader, O3> p3;

  final Parser<StringReader, O4> p4;

  final Parser<StringReader, O5> p5;

  final Parser<StringReader, O6> p6;

  const Recognize6(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6,
      {String? name})
      : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Recognize6(
        name: name,
        builder.build(p1),
        builder.build(p2),
        builder.build(p3),
        builder.build(p4),
        builder.build(p5),
        builder.build(p6));
  }

  @override
  bool fastParse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = p2.fastParse(state);
      if (r2) {
        final r3 = p3.fastParse(state);
        if (r3) {
          final r4 = p4.fastParse(state);
          if (r4) {
            final r5 = p5.fastParse(state);
            if (r5) {
              final r6 = p6.fastParse(state);
              if (r6) {
                return true;
              }
            }
          }
        }
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        final r3 = p3.parse(state);
        if (r3 != null) {
          final r4 = p4.parse(state);
          if (r4 != null) {
            final r5 = p5.parse(state);
            if (r5 != null) {
              final r6 = p6.parse(state);
              if (r6 != null) {
                return state.pos != pos
                    ? Result(state.input.substring(pos, state.pos))
                    : const Result('');
              }
            }
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<String>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O1> r1;
    late AsyncResult<O2> r2;
    late AsyncResult<O3> r3;
    late AsyncResult<O4> r4;
    late AsyncResult<O5> r5;
    late AsyncResult<O6> r6;
    var action = 0;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = p1.parseAsync(state);
            action = 1;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 1:
            if (r1.ok == false) {
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r2 = p2.parseAsync(state);
            action = 2;
            if (r2.ok == null) {
              r2.handler = parse;
              return;
            }

            break;
          case 2:
            if (r2.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r3 = p3.parseAsync(state);
            action = 3;
            if (r3.ok == null) {
              r3.handler = parse;
              return;
            }

            break;
          case 3:
            if (r3.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r4 = p4.parseAsync(state);
            action = 4;
            if (r4.ok == null) {
              r4.handler = parse;
              return;
            }

            break;
          case 4:
            if (r4.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r5 = p5.parseAsync(state);
            action = 5;
            if (r5.ok == null) {
              r5.handler = parse;
              return;
            }

            break;
          case 5:
            if (r5.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r6 = p6.parseAsync(state);
            action = 6;
            if (r6.ok == null) {
              r6.handler = parse;
              return;
            }

            break;
          case 6:
            if ((result.ok = r6.ok) == false) {
              state.pos = pos;
            } else {
              result.value =
                  Result(input.data.source.substring(pos, state.pos));
            }

            input.handler = result.handler;
            action = -1;
            return;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}

/// Stores the current parsing position and invokes all specified parsers.
///
/// Parsing succeeds if the parsing of all parsers succeeds.
///
/// Otherwise, parsing fails.
///
/// Returns: Input string value from the stored position to the last parsed
/// position.
class Recognize7<O1, O2, O3, O4, O5, O6, O7>
    extends Parser<StringReader, String> {
  final Parser<StringReader, O1> p1;

  final Parser<StringReader, O2> p2;

  final Parser<StringReader, O3> p3;

  final Parser<StringReader, O4> p4;

  final Parser<StringReader, O5> p5;

  final Parser<StringReader, O6> p6;

  final Parser<StringReader, O7> p7;

  const Recognize7(
      this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7,
      {String? name})
      : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Recognize7(
        name: name,
        builder.build(p1),
        builder.build(p2),
        builder.build(p3),
        builder.build(p4),
        builder.build(p5),
        builder.build(p6),
        builder.build(p7));
  }

  @override
  bool fastParse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = p2.fastParse(state);
      if (r2) {
        final r3 = p3.fastParse(state);
        if (r3) {
          final r4 = p4.fastParse(state);
          if (r4) {
            final r5 = p5.fastParse(state);
            if (r5) {
              final r6 = p6.fastParse(state);
              if (r6) {
                final r7 = p7.fastParse(state);
                if (r7) {
                  return true;
                }
              }
            }
          }
        }
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        final r3 = p3.parse(state);
        if (r3 != null) {
          final r4 = p4.parse(state);
          if (r4 != null) {
            final r5 = p5.parse(state);
            if (r5 != null) {
              final r6 = p6.parse(state);
              if (r6 != null) {
                final r7 = p7.parse(state);
                if (r7 != null) {
                  return state.pos != pos
                      ? Result(state.input.substring(pos, state.pos))
                      : const Result('');
                }
              }
            }
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<String>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O1> r1;
    late AsyncResult<O2> r2;
    late AsyncResult<O3> r3;
    late AsyncResult<O4> r4;
    late AsyncResult<O5> r5;
    late AsyncResult<O6> r6;
    late AsyncResult<O7> r7;
    var action = 0;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = p1.parseAsync(state);
            action = 1;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 1:
            if (r1.ok == false) {
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r2 = p2.parseAsync(state);
            action = 2;
            if (r2.ok == null) {
              r2.handler = parse;
              return;
            }

            break;
          case 2:
            if (r2.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r3 = p3.parseAsync(state);
            action = 3;
            if (r3.ok == null) {
              r3.handler = parse;
              return;
            }

            break;
          case 3:
            if (r3.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r4 = p4.parseAsync(state);
            action = 4;
            if (r4.ok == null) {
              r4.handler = parse;
              return;
            }

            break;
          case 4:
            if (r4.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r5 = p5.parseAsync(state);
            action = 5;
            if (r5.ok == null) {
              r5.handler = parse;
              return;
            }

            break;
          case 5:
            if (r5.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r6 = p6.parseAsync(state);
            action = 6;
            if (r6.ok == null) {
              r6.handler = parse;
              return;
            }

            break;
          case 6:
            if (r6.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r7 = p7.parseAsync(state);
            action = 7;
            if (r7.ok == null) {
              r7.handler = parse;
              return;
            }

            break;
          case 7:
            if ((result.ok = r7.ok) == false) {
              state.pos = pos;
            } else {
              result.value =
                  Result(input.data.source.substring(pos, state.pos));
            }

            input.handler = result.handler;
            action = -1;
            return;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}

/// Stores the current parsing position and invokes all specified parsers.
///
/// Parsing succeeds if the parsing of all parsers succeeds.
///
/// Otherwise, parsing fails.
///
/// Returns: Input string value from the stored position to the last parsed
/// position.
class Recognize8<O1, O2, O3, O4, O5, O6, O7, O8>
    extends Parser<StringReader, String> {
  final Parser<StringReader, O1> p1;

  final Parser<StringReader, O2> p2;

  final Parser<StringReader, O3> p3;

  final Parser<StringReader, O4> p4;

  final Parser<StringReader, O5> p5;

  final Parser<StringReader, O6> p6;

  final Parser<StringReader, O7> p7;

  final Parser<StringReader, O8> p8;

  const Recognize8(
      this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7, this.p8,
      {String? name})
      : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Recognize8(
        name: name,
        builder.build(p1),
        builder.build(p2),
        builder.build(p3),
        builder.build(p4),
        builder.build(p5),
        builder.build(p6),
        builder.build(p7),
        builder.build(p8));
  }

  @override
  bool fastParse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = p2.fastParse(state);
      if (r2) {
        final r3 = p3.fastParse(state);
        if (r3) {
          final r4 = p4.fastParse(state);
          if (r4) {
            final r5 = p5.fastParse(state);
            if (r5) {
              final r6 = p6.fastParse(state);
              if (r6) {
                final r7 = p7.fastParse(state);
                if (r7) {
                  final r8 = p8.fastParse(state);
                  if (r8) {
                    return true;
                  }
                }
              }
            }
          }
        }
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        final r3 = p3.parse(state);
        if (r3 != null) {
          final r4 = p4.parse(state);
          if (r4 != null) {
            final r5 = p5.parse(state);
            if (r5 != null) {
              final r6 = p6.parse(state);
              if (r6 != null) {
                final r7 = p7.parse(state);
                if (r7 != null) {
                  final r8 = p8.parse(state);
                  if (r8 != null) {
                    return state.pos != pos
                        ? Result(state.input.substring(pos, state.pos))
                        : const Result('');
                  }
                }
              }
            }
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<String>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O1> r1;
    late AsyncResult<O2> r2;
    late AsyncResult<O3> r3;
    late AsyncResult<O4> r4;
    late AsyncResult<O5> r5;
    late AsyncResult<O6> r6;
    late AsyncResult<O7> r7;
    late AsyncResult<O8> r8;
    var action = 0;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = p1.parseAsync(state);
            action = 1;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 1:
            if (r1.ok == false) {
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r2 = p2.parseAsync(state);
            action = 2;
            if (r2.ok == null) {
              r2.handler = parse;
              return;
            }

            break;
          case 2:
            if (r2.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r3 = p3.parseAsync(state);
            action = 3;
            if (r3.ok == null) {
              r3.handler = parse;
              return;
            }

            break;
          case 3:
            if (r3.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r4 = p4.parseAsync(state);
            action = 4;
            if (r4.ok == null) {
              r4.handler = parse;
              return;
            }

            break;
          case 4:
            if (r4.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r5 = p5.parseAsync(state);
            action = 5;
            if (r5.ok == null) {
              r5.handler = parse;
              return;
            }

            break;
          case 5:
            if (r5.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r6 = p6.parseAsync(state);
            action = 6;
            if (r6.ok == null) {
              r6.handler = parse;
              return;
            }

            break;
          case 6:
            if (r6.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r7 = p7.parseAsync(state);
            action = 7;
            if (r7.ok == null) {
              r7.handler = parse;
              return;
            }

            break;
          case 7:
            if (r7.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r8 = p8.parseAsync(state);
            action = 8;
            if (r8.ok == null) {
              r8.handler = parse;
              return;
            }

            break;
          case 8:
            if ((result.ok = r8.ok) == false) {
              state.pos = pos;
            } else {
              result.value =
                  Result(input.data.source.substring(pos, state.pos));
            }

            input.handler = result.handler;
            action = -1;
            return;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}

/// Stores the current parsing position and invokes all specified parsers.
///
/// Parsing succeeds if the parsing of all parsers succeeds.
///
/// Otherwise, parsing fails.
///
/// Returns: Input string value from the stored position to the last parsed
/// position.
class Recognize9<O1, O2, O3, O4, O5, O6, O7, O8, O9>
    extends Parser<StringReader, String> {
  final Parser<StringReader, O1> p1;

  final Parser<StringReader, O2> p2;

  final Parser<StringReader, O3> p3;

  final Parser<StringReader, O4> p4;

  final Parser<StringReader, O5> p5;

  final Parser<StringReader, O6> p6;

  final Parser<StringReader, O7> p7;

  final Parser<StringReader, O8> p8;

  final Parser<StringReader, O9> p9;

  const Recognize9(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6,
      this.p7, this.p8, this.p9,
      {String? name})
      : super(name);

  @override
  Parser<StringReader, String> build(ParserBuilder<StringReader> builder) {
    return Recognize9(
        name: name,
        builder.build(p1),
        builder.build(p2),
        builder.build(p3),
        builder.build(p4),
        builder.build(p5),
        builder.build(p6),
        builder.build(p7),
        builder.build(p8),
        builder.build(p9));
  }

  @override
  bool fastParse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = p2.fastParse(state);
      if (r2) {
        final r3 = p3.fastParse(state);
        if (r3) {
          final r4 = p4.fastParse(state);
          if (r4) {
            final r5 = p5.fastParse(state);
            if (r5) {
              final r6 = p6.fastParse(state);
              if (r6) {
                final r7 = p7.fastParse(state);
                if (r7) {
                  final r8 = p8.fastParse(state);
                  if (r8) {
                    final r9 = p9.fastParse(state);
                    if (r9) {
                      return true;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    state.pos = pos;
    return false;
  }

  @override
  Result<String>? parse(State<StringReader> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        final r3 = p3.parse(state);
        if (r3 != null) {
          final r4 = p4.parse(state);
          if (r4 != null) {
            final r5 = p5.parse(state);
            if (r5 != null) {
              final r6 = p6.parse(state);
              if (r6 != null) {
                final r7 = p7.parse(state);
                if (r7 != null) {
                  final r8 = p8.parse(state);
                  if (r8 != null) {
                    final r9 = p9.parse(state);
                    if (r9 != null) {
                      return state.pos != pos
                          ? Result(state.input.substring(pos, state.pos))
                          : const Result('');
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  AsyncResult<String> parseAsync(State<ChunkedData<StringReader>> state) {
    final result = AsyncResult<String>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O1> r1;
    late AsyncResult<O2> r2;
    late AsyncResult<O3> r3;
    late AsyncResult<O4> r4;
    late AsyncResult<O5> r5;
    late AsyncResult<O6> r6;
    late AsyncResult<O7> r7;
    late AsyncResult<O8> r8;
    late AsyncResult<O9> r9;
    var action = 0;
    void parse() {
      while (true) {
        switch (action) {
          case 0:
            r1 = p1.parseAsync(state);
            action = 1;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 1:
            if (r1.ok == false) {
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r2 = p2.parseAsync(state);
            action = 2;
            if (r2.ok == null) {
              r2.handler = parse;
              return;
            }

            break;
          case 2:
            if (r2.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r3 = p3.parseAsync(state);
            action = 3;
            if (r3.ok == null) {
              r3.handler = parse;
              return;
            }

            break;
          case 3:
            if (r3.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r4 = p4.parseAsync(state);
            action = 4;
            if (r4.ok == null) {
              r4.handler = parse;
              return;
            }

            break;
          case 4:
            if (r4.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r5 = p5.parseAsync(state);
            action = 5;
            if (r5.ok == null) {
              r5.handler = parse;
              return;
            }

            break;
          case 5:
            if (r5.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r6 = p6.parseAsync(state);
            action = 6;
            if (r6.ok == null) {
              r6.handler = parse;
              return;
            }

            break;
          case 6:
            if (r6.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r7 = p7.parseAsync(state);
            action = 7;
            if (r7.ok == null) {
              r7.handler = parse;
              return;
            }

            break;
          case 7:
            if (r7.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r8 = p8.parseAsync(state);
            action = 8;
            if (r8.ok == null) {
              r8.handler = parse;
              return;
            }

            break;
          case 8:
            if (r8.ok == false) {
              state.pos = pos;
              result.ok = false;
              input.handler = result.handler;
              return;
            }

            r9 = p9.parseAsync(state);
            action = 9;
            if (r9.ok == null) {
              r9.handler = parse;
              return;
            }

            break;
          case 9:
            if ((result.ok = r9.ok) == false) {
              state.pos = pos;
            } else {
              result.value =
                  Result(input.data.source.substring(pos, state.pos));
            }

            input.handler = result.handler;
            action = -1;
            return;
          default:
            throw StateError('Invalid state: $action');
        }
      }
    }

    parse();
    return result;
  }
}
