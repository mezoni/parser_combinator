import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Tuple2<I, O1, O2> extends Parser<I, (O1, O2)> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  const Tuple2(this.p1, this.p2, {String? name}) : super(name);

  @override
  Parser<I, (O1, O2)> build(ParserBuilder<I> builder) {
    return Tuple2(
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
  Result<(O1, O2)>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        return Result((
          r1.value,
          r2.value,
        ));
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseStream(
      State<ChunkedData<I>> state, VoidCallback1<(O1, O2)> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O1>? r1;
    Result<O2>? r2;
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
          onDone(Result((
            r1!.value,
            r2!.value,
          )));
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

class Tuple3<I, O1, O2, O3> extends Parser<I, (O1, O2, O3)> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  const Tuple3(this.p1, this.p2, this.p3, {String? name}) : super(name);

  @override
  Parser<I, (O1, O2, O3)> build(ParserBuilder<I> builder) {
    return Tuple3(
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
  Result<(O1, O2, O3)>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        final r3 = p3.parse(state);
        if (r3 != null) {
          return Result((
            r1.value,
            r2.value,
            r3.value,
          ));
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseStream(
      State<ChunkedData<I>> state, VoidCallback1<(O1, O2, O3)> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O1>? r1;
    Result<O2>? r2;
    Result<O3>? r3;
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
          onDone(Result((
            r1!.value,
            r2!.value,
            r3!.value,
          )));
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

class Tuple4<I, O1, O2, O3, O4> extends Parser<I, (O1, O2, O3, O4)> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  const Tuple4(this.p1, this.p2, this.p3, this.p4, {String? name})
      : super(name);

  @override
  Parser<I, (O1, O2, O3, O4)> build(ParserBuilder<I> builder) {
    return Tuple4(
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
  Result<(O1, O2, O3, O4)>? parse(State<I> state) {
    final pos = state.pos;
    final r1 = p1.parse(state);
    if (r1 != null) {
      final r2 = p2.parse(state);
      if (r2 != null) {
        final r3 = p3.parse(state);
        if (r3 != null) {
          final r4 = p4.parse(state);
          if (r4 != null) {
            return Result((
              r1.value,
              r2.value,
              r3.value,
              r4.value,
            ));
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseStream(
      State<ChunkedData<I>> state, VoidCallback1<(O1, O2, O3, O4)> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O1>? r1;
    Result<O2>? r2;
    Result<O3>? r3;
    Result<O4>? r4;
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
          onDone(Result((
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
          )));
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

class Tuple5<I, O1, O2, O3, O4, O5> extends Parser<I, (O1, O2, O3, O4, O5)> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  final Parser<I, O5> p5;

  const Tuple5(this.p1, this.p2, this.p3, this.p4, this.p5, {String? name})
      : super(name);

  @override
  Parser<I, (O1, O2, O3, O4, O5)> build(ParserBuilder<I> builder) {
    return Tuple5(
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
  Result<(O1, O2, O3, O4, O5)>? parse(State<I> state) {
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
              return Result((
                r1.value,
                r2.value,
                r3.value,
                r4.value,
                r5.value,
              ));
            }
          }
        }
      }
    }

    state.pos = pos;
    return null;
  }

  @override
  void parseStream(
      State<ChunkedData<I>> state, VoidCallback1<(O1, O2, O3, O4, O5)> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O1>? r1;
    Result<O2>? r2;
    Result<O3>? r3;
    Result<O4>? r4;
    Result<O5>? r5;
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
          onDone(Result((
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
            r5!.value,
          )));
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

class Tuple6<I, O1, O2, O3, O4, O5, O6>
    extends Parser<I, (O1, O2, O3, O4, O5, O6)> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  final Parser<I, O5> p5;

  final Parser<I, O6> p6;

  const Tuple6(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6,
      {String? name})
      : super(name);

  @override
  Parser<I, (O1, O2, O3, O4, O5, O6)> build(ParserBuilder<I> builder) {
    return Tuple6(
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
  Result<(O1, O2, O3, O4, O5, O6)>? parse(State<I> state) {
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
                return Result((
                  r1.value,
                  r2.value,
                  r3.value,
                  r4.value,
                  r5.value,
                  r6.value,
                ));
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
  void parseStream(State<ChunkedData<I>> state,
      VoidCallback1<(O1, O2, O3, O4, O5, O6)> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O1>? r1;
    Result<O2>? r2;
    Result<O3>? r3;
    Result<O4>? r4;
    Result<O5>? r5;
    Result<O6>? r6;
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
          onDone(Result((
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
            r5!.value,
            r6!.value,
          )));
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

class Tuple7<I, O1, O2, O3, O4, O5, O6, O7>
    extends Parser<I, (O1, O2, O3, O4, O5, O6, O7)> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  final Parser<I, O5> p5;

  final Parser<I, O6> p6;

  final Parser<I, O7> p7;

  const Tuple7(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7,
      {String? name})
      : super(name);

  @override
  Parser<I, (O1, O2, O3, O4, O5, O6, O7)> build(ParserBuilder<I> builder) {
    return Tuple7(
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
  Result<(O1, O2, O3, O4, O5, O6, O7)>? parse(State<I> state) {
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
                  return Result((
                    r1.value,
                    r2.value,
                    r3.value,
                    r4.value,
                    r5.value,
                    r6.value,
                    r7.value,
                  ));
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
  void parseStream(State<ChunkedData<I>> state,
      VoidCallback1<(O1, O2, O3, O4, O5, O6, O7)> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O1>? r1;
    Result<O2>? r2;
    Result<O3>? r3;
    Result<O4>? r4;
    Result<O5>? r5;
    Result<O6>? r6;
    Result<O7>? r7;
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
          onDone(Result((
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
            r5!.value,
            r6!.value,
            r7!.value,
          )));
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

class Tuple8<I, O1, O2, O3, O4, O5, O6, O7, O8>
    extends Parser<I, (O1, O2, O3, O4, O5, O6, O7, O8)> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  final Parser<I, O5> p5;

  final Parser<I, O6> p6;

  final Parser<I, O7> p7;

  final Parser<I, O8> p8;

  const Tuple8(
      this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7, this.p8,
      {String? name})
      : super(name);

  @override
  Parser<I, (O1, O2, O3, O4, O5, O6, O7, O8)> build(ParserBuilder<I> builder) {
    return Tuple8(
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
  Result<(O1, O2, O3, O4, O5, O6, O7, O8)>? parse(State<I> state) {
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
                    return Result((
                      r1.value,
                      r2.value,
                      r3.value,
                      r4.value,
                      r5.value,
                      r6.value,
                      r7.value,
                      r8.value,
                    ));
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
  void parseStream(State<ChunkedData<I>> state,
      VoidCallback1<(O1, O2, O3, O4, O5, O6, O7, O8)> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O1>? r1;
    Result<O2>? r2;
    Result<O3>? r3;
    Result<O4>? r4;
    Result<O5>? r5;
    Result<O6>? r6;
    Result<O7>? r7;
    Result<O8>? r8;
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
          onDone(Result((
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
            r5!.value,
            r6!.value,
            r7!.value,
            r8!.value,
          )));
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

class Tuple9<I, O1, O2, O3, O4, O5, O6, O7, O8, O9>
    extends Parser<I, (O1, O2, O3, O4, O5, O6, O7, O8, O9)> {
  final Parser<I, O1> p1;

  final Parser<I, O2> p2;

  final Parser<I, O3> p3;

  final Parser<I, O4> p4;

  final Parser<I, O5> p5;

  final Parser<I, O6> p6;

  final Parser<I, O7> p7;

  final Parser<I, O8> p8;

  final Parser<I, O9> p9;

  const Tuple9(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7,
      this.p8, this.p9,
      {String? name})
      : super(name);

  @override
  Parser<I, (O1, O2, O3, O4, O5, O6, O7, O8, O9)> build(
      ParserBuilder<I> builder) {
    return Tuple9(
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
  Result<(O1, O2, O3, O4, O5, O6, O7, O8, O9)>? parse(State<I> state) {
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
                      return Result((
                        r1.value,
                        r2.value,
                        r3.value,
                        r4.value,
                        r5.value,
                        r6.value,
                        r7.value,
                        r8.value,
                        r9.value,
                      ));
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
  void parseStream(State<ChunkedData<I>> state,
      VoidCallback1<(O1, O2, O3, O4, O5, O6, O7, O8, O9)> onDone) {
    final input = state.input;
    final index0 = input.index0;
    final index1 = input.index1;
    final index2 = input.index2;
    final pos = state.pos;
    Result<O1>? r1;
    Result<O2>? r2;
    Result<O3>? r3;
    Result<O4>? r4;
    Result<O5>? r5;
    Result<O6>? r6;
    Result<O7>? r7;
    Result<O8>? r8;
    Result<O9>? r9;
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
          onDone(Result((
            r1!.value,
            r2!.value,
            r3!.value,
            r4!.value,
            r5!.value,
            r6!.value,
            r7!.value,
            r8!.value,
            r9!.value
          )));
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
