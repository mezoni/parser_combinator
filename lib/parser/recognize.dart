import '../parser_combinator.dart';
import '../runtime.dart';
import '../string_reader.dart';

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
}

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
}

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
}

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
}

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
}

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
}

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
}

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
}

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
}
