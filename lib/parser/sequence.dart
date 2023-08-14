import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Sequence1<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p;

  const Sequence1(this.p, {String? name}) : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return Sequence1(
      name: name,
      builder.build(p),
    );
  }

  @override
  bool fastParse(State<I> state) {
    return p.fastParse(state);
  }

  @override
  Result<List<O>>? parse(State<I> state) {
    final r = p.parse(state);
    if (r != null) {
      return Result([r.value]);
    }

    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<List<O>> onDone) {
    void parse() {
      p.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          onDone(Result([result.value]));
        }
      });
    }

    parse();
  }
}

class Sequence2<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  const Sequence2(this.p1, this.p2, {String? name}) : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return Sequence2(
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
  Result<List<O>>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        return Result([r1.value, r2.value]);
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<List<O>> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O>? r1;
    Result<O>? r2;
    void parse2() {
      p2.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          r2 = result;
          onDone(Result([
            r1!.value,
            r2!.value,
          ]));
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          r1 = result;
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Sequence3<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  const Sequence3(this.p1, this.p2, this.p3, {String? name}) : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return Sequence3(
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
  Result<List<O>>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        final r3 = p3.parse(state);
        if (r3 != null) {
          return Result([r1.value, r2.value, r3.value]);
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<List<O>> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O>? r1;
    Result<O>? r2;
    Result<O>? r3;
    void parse3() {
      p3.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          r3 = result;
          onDone(Result([
            r1!.value,
            r2!.value,
            r3!.value,
          ]));
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
          r2 = result;
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          r1 = result;
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Sequence4<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  const Sequence4(this.p1, this.p2, this.p3, this.p4, {String? name})
      : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return Sequence4(
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
  Result<List<O>>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        final r3 = p3.parse(state);
        if (r3 != null) {
          final r4 = p4.parse(state);
          if (r4 != null) {
            return Result([r1.value, r2.value, r3.value, r4.value]);
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<List<O>> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O>? r1;
    Result<O>? r2;
    Result<O>? r3;
    Result<O>? r4;
    void parse4() {
      p4.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          r4 = result;
          onDone(Result([
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
          ]));
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
          r3 = result;
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
          r2 = result;
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          r1 = result;
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Sequence5<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  final Parser<I, O> p5;

  const Sequence5(this.p1, this.p2, this.p3, this.p4, this.p5, {String? name})
      : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return Sequence5(
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
  Result<List<O>>? parse(State<I> state) {
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
              return Result([r1.value, r2.value, r3.value, r4.value, r5.value]);
            }
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<List<O>> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O>? r1;
    Result<O>? r2;
    Result<O>? r3;
    Result<O>? r4;
    Result<O>? r5;
    void parse5() {
      p5.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          r5 = result;
          onDone(Result([
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
            r5!.value,
          ]));
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
          r4 = result;
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
          r3 = result;
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
          r2 = result;
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          r1 = result;
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Sequence6<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  final Parser<I, O> p5;

  final Parser<I, O> p6;

  const Sequence6(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6,
      {String? name})
      : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return Sequence6(
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
  Result<List<O>>? parse(State<I> state) {
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
                return Result([
                  r1.value,
                  r2.value,
                  r3.value,
                  r4.value,
                  r5.value,
                  r6.value
                ]);
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
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<List<O>> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O>? r1;
    Result<O>? r2;
    Result<O>? r3;
    Result<O>? r4;
    Result<O>? r5;
    Result<O>? r6;
    void parse6() {
      p6.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          r6 = result;
          onDone(Result([
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
            r5!.value,
            r6!.value,
          ]));
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
          r5 = result;
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
          r4 = result;
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
          r3 = result;
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
          r2 = result;
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          r1 = result;
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Sequence7<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  final Parser<I, O> p5;

  final Parser<I, O> p6;

  final Parser<I, O> p7;

  const Sequence7(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7,
      {String? name})
      : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return Sequence7(
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
  Result<List<O>>? parse(State<I> state) {
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
                  return Result([
                    r1.value,
                    r2.value,
                    r3.value,
                    r4.value,
                    r5.value,
                    r6.value,
                    r7.value
                  ]);
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
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<List<O>> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O>? r1;
    Result<O>? r2;
    Result<O>? r3;
    Result<O>? r4;
    Result<O>? r5;
    Result<O>? r6;
    Result<O>? r7;
    void parse7() {
      p7.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          r7 = result;
          onDone(Result([
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
            r5!.value,
            r6!.value,
            r7!.value,
          ]));
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
          r6 = result;
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
          r5 = result;
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
          r4 = result;
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
          r3 = result;
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
          r2 = result;
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          r1 = result;
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Sequence8<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  final Parser<I, O> p5;

  final Parser<I, O> p6;

  final Parser<I, O> p7;

  final Parser<I, O> p8;

  const Sequence8(
      this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7, this.p8,
      {String? name})
      : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return Sequence8(
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
  Result<List<O>>? parse(State<I> state) {
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
                    return Result([
                      r1.value,
                      r2.value,
                      r3.value,
                      r4.value,
                      r5.value,
                      r6.value,
                      r7.value,
                      r8.value
                    ]);
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
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<List<O>> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O>? r1;
    Result<O>? r2;
    Result<O>? r3;
    Result<O>? r4;
    Result<O>? r5;
    Result<O>? r6;
    Result<O>? r7;
    Result<O>? r8;
    void parse8() {
      p8.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          r8 = result;
          onDone(Result([
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
            r5!.value,
            r6!.value,
            r7!.value,
            r8!.value,
          ]));
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
          r7 = result;
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
          r6 = result;
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
          r5 = result;
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
          r4 = result;
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
          r3 = result;
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
          r2 = result;
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          r1 = result;
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}

class Sequence9<I, O> extends Parser<I, List<O>> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  final Parser<I, O> p5;

  final Parser<I, O> p6;

  final Parser<I, O> p7;

  final Parser<I, O> p8;

  final Parser<I, O> p9;

  const Sequence9(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7,
      this.p8, this.p9,
      {String? name})
      : super(name);

  @override
  Parser<I, List<O>> build(ParserBuilder<I> builder) {
    return Sequence9(
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
  Result<List<O>>? parse(State<I> state) {
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
                      return Result([
                        r1.value,
                        r2.value,
                        r3.value,
                        r4.value,
                        r5.value,
                        r6.value,
                        r7.value,
                        r8.value,
                        r9.value
                      ]);
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
  void parseStream(State<ChunkedData<I>> state, VoidCallback1<List<O>> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O>? r1;
    Result<O>? r2;
    Result<O>? r3;
    Result<O>? r4;
    Result<O>? r5;
    Result<O>? r6;
    Result<O>? r7;
    Result<O>? r8;
    Result<O>? r9;
    void parse9() {
      p9.parseStream(state, (result) {
        if (result == null) {
          state.pos = pos;
          input.index0 = index0;
          input.index1 = index1;
          input.index2 = index2;
          onDone(null);
        } else {
          r9 = result;
          onDone(Result([
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
            r5!.value,
            r6!.value,
            r7!.value,
            r8!.value,
            r9!.value
          ]));
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
          r8 = result;
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
          r7 = result;
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
          r6 = result;
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
          r5 = result;
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
          r4 = result;
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
          r3 = result;
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
          r2 = result;
          input.handle(parse3);
        }
      });
    }

    void parse() {
      p1.parseStream(state, (result) {
        if (result == null) {
          onDone(null);
        } else {
          r1 = result;
          input.handle(parse2);
        }
      });
    }

    parse();
  }
}
