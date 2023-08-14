import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Fast2<I, O1, O2> extends Parser<I, Object?> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  const Fast2(this.p1, this.p2, {String? name}) : super(name);

  @override
  Parser<I, Object?> build(ParserBuilder<I> builder) {
    return Fast2(
      name: name,
      builder.build(p1),
      builder.build(p2),
    );
  }

  @override
  bool fastParse(State<I> state) {
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
  Result<Object?>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = p2.fastParse(state);
      if (r2) {
        return const Result(null);
      }

      state.pos = pos;
    }

    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<Object?> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    void parse2() {
      p2.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          onDone(Result(null));
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Fast3<I, O1, O2, O3> extends Parser<I, Object?> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  const Fast3(this.p1, this.p2, this.p3, {String? name}) : super(name);

  @override
  Parser<I, Object?> build(ParserBuilder<I> builder) {
    return Fast3(
      name: name,
      builder.build(p1),
      builder.build(p2),
      builder.build(p3),
    );
  }

  @override
  bool fastParse(State<I> state) {
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
  Result<Object?>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = p2.fastParse(state);
      if (r2) {
        final r3 = p3.fastParse(state);
        if (r3) {
          return const Result(null);
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<Object?> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    void parse3() {
      p3.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          onDone(Result(null));
        }
      });
    }

    void parse2() {
      p2.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Fast4<I, O1, O2, O3, O4> extends Parser<I, Object?> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  const Fast4(this.p1, this.p2, this.p3, this.p4, {String? name}) : super(name);

  @override
  Parser<I, Object?> build(ParserBuilder<I> builder) {
    return Fast4(
      name: name,
      builder.build(p1),
      builder.build(p2),
      builder.build(p3),
      builder.build(p4),
    );
  }

  @override
  bool fastParse(State<I> state) {
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
  Result<Object?>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.fastParse(state);
    if (r1) {
      final r2 = p2.fastParse(state);
      if (r2) {
        final r3 = p3.fastParse(state);
        if (r3) {
          final r4 = p4.fastParse(state);
          if (r4) {
            return const Result(null);
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<Object?> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    void parse4() {
      p4.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          onDone(Result(null));
        }
      });
    }

    void parse3() {
      p3.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse4);
        }
      });
    }

    void parse2() {
      p2.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Fast5<I, O1, O2, O3, O4, O5> extends Parser<I, Object?> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  final Parser<I, O5> p5;

  const Fast5(this.p1, this.p2, this.p3, this.p4, this.p5, {String? name})
      : super(name);

  @override
  Parser<I, Object?> build(ParserBuilder<I> builder) {
    return Fast5(
      name: name,
      builder.build(p1),
      builder.build(p2),
      builder.build(p3),
      builder.build(p4),
      builder.build(p5),
    );
  }

  @override
  bool fastParse(State<I> state) {
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
  Result<Object?>? parse(State<I> state) {
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
              return const Result(null);
            }
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<Object?> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    void parse5() {
      p5.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          onDone(Result(null));
        }
      });
    }

    void parse4() {
      p4.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse5);
        }
      });
    }

    void parse3() {
      p3.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse4);
        }
      });
    }

    void parse2() {
      p2.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Fast6<I, O1, O2, O3, O4, O5, O6> extends Parser<I, Object?> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  final Parser<I, O5> p5;

  final Parser<I, O6> p6;

  const Fast6(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6,
      {String? name})
      : super(name);

  @override
  Parser<I, Object?> build(ParserBuilder<I> builder) {
    return Fast6(
      name: name,
      builder.build(p1),
      builder.build(p2),
      builder.build(p3),
      builder.build(p4),
      builder.build(p5),
      builder.build(p6),
    );
  }

  @override
  bool fastParse(State<I> state) {
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
  Result<Object?>? parse(State<I> state) {
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
                return const Result(null);
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
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<Object?> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    void parse6() {
      p6.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          onDone(Result(null));
        }
      });
    }

    void parse5() {
      p5.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse6);
        }
      });
    }

    void parse4() {
      p4.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse5);
        }
      });
    }

    void parse3() {
      p3.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse4);
        }
      });
    }

    void parse2() {
      p2.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Fast7<I, O1, O2, O3, O4, O5, O6, O7> extends Parser<I, Object?> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  final Parser<I, O5> p5;

  final Parser<I, O6> p6;

  final Parser<I, O7> p7;

  const Fast7(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7,
      {String? name})
      : super(name);

  @override
  Parser<I, Object?> build(ParserBuilder<I> builder) {
    return Fast7(
      name: name,
      builder.build(p1),
      builder.build(p2),
      builder.build(p3),
      builder.build(p4),
      builder.build(p5),
      builder.build(p6),
      builder.build(p7),
    );
  }

  @override
  bool fastParse(State<I> state) {
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
  Result<Object?>? parse(State<I> state) {
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
                  return const Result(null);
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
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<Object?> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    void parse7() {
      p7.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          onDone(Result(null));
        }
      });
    }

    void parse6() {
      p6.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse7);
        }
      });
    }

    void parse5() {
      p5.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse6);
        }
      });
    }

    void parse4() {
      p4.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse5);
        }
      });
    }

    void parse3() {
      p3.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse4);
        }
      });
    }

    void parse2() {
      p2.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Fast8<I, O1, O2, O3, O4, O5, O6, O7, O8> extends Parser<I, Object?> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  final Parser<I, O5> p5;

  final Parser<I, O6> p6;

  final Parser<I, O7> p7;

  final Parser<I, O8> p8;

  const Fast8(
      this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7, this.p8,
      {String? name})
      : super(name);

  @override
  Parser<I, Object?> build(ParserBuilder<I> builder) {
    return Fast8(
      name: name,
      builder.build(p1),
      builder.build(p2),
      builder.build(p3),
      builder.build(p4),
      builder.build(p5),
      builder.build(p6),
      builder.build(p7),
      builder.build(p8),
    );
  }

  @override
  bool fastParse(State<I> state) {
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
  Result<Object?>? parse(State<I> state) {
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
                    return const Result(null);
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
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<Object?> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    void parse8() {
      p8.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          onDone(Result(null));
        }
      });
    }

    void parse7() {
      p7.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse8);
        }
      });
    }

    void parse6() {
      p6.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse7);
        }
      });
    }

    void parse5() {
      p5.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse6);
        }
      });
    }

    void parse4() {
      p4.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse5);
        }
      });
    }

    void parse3() {
      p3.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse4);
        }
      });
    }

    void parse2() {
      p2.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Fast9<I, O1, O2, O3, O4, O5, O6, O7, O8, O9> extends Parser<I, Object?> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  final Parser<I, O5> p5;

  final Parser<I, O6> p6;

  final Parser<I, O7> p7;

  final Parser<I, O8> p8;

  final Parser<I, O9> p9;

  const Fast9(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7,
      this.p8, this.p9,
      {String? name})
      : super(name);

  @override
  Parser<I, Object?> build(ParserBuilder<I> builder) {
    return Fast9(
      name: name,
      builder.build(p1),
      builder.build(p2),
      builder.build(p3),
      builder.build(p4),
      builder.build(p5),
      builder.build(p6),
      builder.build(p7),
      builder.build(p8),
      builder.build(p9),
    );
  }

  @override
  bool fastParse(State<I> state) {
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
  Result<Object?>? parse(State<I> state) {
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
                      return const Result(null);
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
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<Object?> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    void parse9() {
      p9.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          onDone(Result(null));
        }
      });
    }

    void parse8() {
      p8.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse9);
        }
      });
    }

    void parse7() {
      p7.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse8);
        }
      });
    }

    void parse6() {
      p6.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse7);
        }
      });
    }

    void parse5() {
      p5.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse6);
        }
      });
    }

    void parse4() {
      p4.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse5);
        }
      });
    }

    void parse3() {
      p3.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse4);
        }
      });
    }

    void parse2() {
      p2.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}
