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
  AsyncResult<List<O>> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<List<O>>();
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
              result.value = Result([
                r1.value!.value,
              ]);
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
  AsyncResult<List<O>> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<List<O>>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O> r1;
    late AsyncResult<O> r2;
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
              result.value = Result([
                r1.value!.value,
                r2.value!.value,
              ]);
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
  AsyncResult<List<O>> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<List<O>>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O> r1;
    late AsyncResult<O> r2;
    late AsyncResult<O> r3;
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
              result.value = Result([
                r1.value!.value,
                r2.value!.value,
                r3.value!.value,
              ]);
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
  AsyncResult<List<O>> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<List<O>>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O> r1;
    late AsyncResult<O> r2;
    late AsyncResult<O> r3;
    late AsyncResult<O> r4;
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
              result.value = Result([
                r1.value!.value,
                r2.value!.value,
                r3.value!.value,
                r4.value!.value,
              ]);
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
  AsyncResult<List<O>> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<List<O>>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O> r1;
    late AsyncResult<O> r2;
    late AsyncResult<O> r3;
    late AsyncResult<O> r4;
    late AsyncResult<O> r5;
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
              result.value = Result([
                r1.value!.value,
                r2.value!.value,
                r3.value!.value,
                r4.value!.value,
                r5.value!.value,
              ]);
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
  AsyncResult<List<O>> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<List<O>>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O> r1;
    late AsyncResult<O> r2;
    late AsyncResult<O> r3;
    late AsyncResult<O> r4;
    late AsyncResult<O> r5;
    late AsyncResult<O> r6;
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
              result.value = Result([
                r1.value!.value,
                r2.value!.value,
                r3.value!.value,
                r4.value!.value,
                r5.value!.value,
                r6.value!.value,
              ]);
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
  AsyncResult<List<O>> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<List<O>>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O> r1;
    late AsyncResult<O> r2;
    late AsyncResult<O> r3;
    late AsyncResult<O> r4;
    late AsyncResult<O> r5;
    late AsyncResult<O> r6;
    late AsyncResult<O> r7;
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
              result.value = Result([
                r1.value!.value,
                r2.value!.value,
                r3.value!.value,
                r4.value!.value,
                r5.value!.value,
                r6.value!.value,
                r7.value!.value,
              ]);
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
  AsyncResult<List<O>> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<List<O>>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O> r1;
    late AsyncResult<O> r2;
    late AsyncResult<O> r3;
    late AsyncResult<O> r4;
    late AsyncResult<O> r5;
    late AsyncResult<O> r6;
    late AsyncResult<O> r7;
    late AsyncResult<O> r8;
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
              result.value = Result([
                r1.value!.value,
                r2.value!.value,
                r3.value!.value,
                r4.value!.value,
                r5.value!.value,
                r6.value!.value,
                r7.value!.value,
                r8.value!.value,
              ]);
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
  AsyncResult<List<O>> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<List<O>>();
    final input = state.input;
    final pos = state.pos;
    late AsyncResult<O> r1;
    late AsyncResult<O> r2;
    late AsyncResult<O> r3;
    late AsyncResult<O> r4;
    late AsyncResult<O> r5;
    late AsyncResult<O> r6;
    late AsyncResult<O> r7;
    late AsyncResult<O> r8;
    late AsyncResult<O> r9;
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
              result.value = Result([
                r1.value!.value,
                r2.value!.value,
                r3.value!.value,
                r4.value!.value,
                r5.value!.value,
                r6.value!.value,
                r7.value!.value,
                r8.value!.value,
                r9.value!.value
              ]);
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
