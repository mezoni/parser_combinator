import '../parser_combinator.dart';
import '../runtime.dart';
import '../streaming.dart';

class Choice2<I, O> extends Parser<I, O> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  const Choice2(this.p1, this.p2, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Choice2(
      name: name,
      builder.build(p1),
      builder.build(p2),
    );
  }

  @override
  bool fastParse(State<I> state) {
    final r1 = p1.fastParse(state);
    if (r1) {
      return r1;
    }

    final r2 = p2.fastParse(state);
    if (r2) {
      return r2;
    }

    return false;
  }

  @override
  Result<O>? parse(State<I> state) {
    final r1 = p1.parse(state);
    if (r1 != null) {
      return r1;
    }

    final r2 = p2.parse(state);
    if (r2 != null) {
      return r2;
    }

    return null;
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O>();
    final input = state.input;
    late AsyncResult<O> r1;
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
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p2.parseAsync(state);
            action = 2;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 2:
            if ((result.ok = r1.ok) == true) {
              result.value = r1.value;
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

class Choice3<I, O> extends Parser<I, O> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  const Choice3(this.p1, this.p2, this.p3, {String? name}) : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Choice3(
      name: name,
      builder.build(p1),
      builder.build(p2),
      builder.build(p3),
    );
  }

  @override
  bool fastParse(State<I> state) {
    final r1 = p1.fastParse(state);
    if (r1) {
      return r1;
    }

    final r2 = p2.fastParse(state);
    if (r2) {
      return r2;
    }

    final r3 = p3.fastParse(state);
    if (r3) {
      return r3;
    }

    return false;
  }

  @override
  Result<O>? parse(State<I> state) {
    final r1 = p1.parse(state);
    if (r1 != null) {
      return r1;
    }

    final r2 = p2.parse(state);
    if (r2 != null) {
      return r2;
    }

    final r3 = p3.parse(state);
    if (r3 != null) {
      return r3;
    }

    return null;
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O>();
    final input = state.input;
    late AsyncResult<O> r1;
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
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p2.parseAsync(state);
            action = 2;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 2:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p3.parseAsync(state);
            action = 3;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 3:
            if ((result.ok = r1.ok) == true) {
              result.value = r1.value;
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

class Choice4<I, O> extends Parser<I, O> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  const Choice4(this.p1, this.p2, this.p3, this.p4, {String? name})
      : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Choice4(
      name: name,
      builder.build(p1),
      builder.build(p2),
      builder.build(p3),
      builder.build(p4),
    );
  }

  @override
  bool fastParse(State<I> state) {
    final r1 = p1.fastParse(state);
    if (r1) {
      return r1;
    }

    final r2 = p2.fastParse(state);
    if (r2) {
      return r2;
    }

    final r3 = p3.fastParse(state);
    if (r3) {
      return r3;
    }

    final r4 = p4.fastParse(state);
    if (r4) {
      return r4;
    }

    return false;
  }

  @override
  Result<O>? parse(State<I> state) {
    final r1 = p1.parse(state);
    if (r1 != null) {
      return r1;
    }

    final r2 = p2.parse(state);
    if (r2 != null) {
      return r2;
    }

    final r3 = p3.parse(state);
    if (r3 != null) {
      return r3;
    }

    final r4 = p4.parse(state);
    if (r4 != null) {
      return r4;
    }

    return null;
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O>();
    final input = state.input;
    late AsyncResult<O> r1;
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
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p2.parseAsync(state);
            action = 2;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 2:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p3.parseAsync(state);
            action = 3;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 3:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p4.parseAsync(state);
            action = 4;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 4:
            if ((result.ok = r1.ok) == true) {
              result.value = r1.value;
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

class Choice5<I, O> extends Parser<I, O> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  final Parser<I, O> p5;

  const Choice5(this.p1, this.p2, this.p3, this.p4, this.p5, {String? name})
      : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Choice5(
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
    final r1 = p1.fastParse(state);
    if (r1) {
      return r1;
    }

    final r2 = p2.fastParse(state);
    if (r2) {
      return r2;
    }

    final r3 = p3.fastParse(state);
    if (r3) {
      return r3;
    }

    final r4 = p4.fastParse(state);
    if (r4) {
      return r4;
    }

    final r5 = p5.fastParse(state);
    if (r5) {
      return r5;
    }

    return false;
  }

  @override
  Result<O>? parse(State<I> state) {
    final r1 = p1.parse(state);
    if (r1 != null) {
      return r1;
    }

    final r2 = p2.parse(state);
    if (r2 != null) {
      return r2;
    }

    final r3 = p3.parse(state);
    if (r3 != null) {
      return r3;
    }

    final r4 = p4.parse(state);
    if (r4 != null) {
      return r4;
    }

    final r5 = p5.parse(state);
    if (r5 != null) {
      return r5;
    }

    return null;
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O>();
    final input = state.input;
    late AsyncResult<O> r1;
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
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p2.parseAsync(state);
            action = 2;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 2:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p3.parseAsync(state);
            action = 3;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 3:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p4.parseAsync(state);
            action = 4;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 4:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p5.parseAsync(state);
            action = 5;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 5:
            if ((result.ok = r1.ok) == true) {
              result.value = r1.value;
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

class Choice6<I, O> extends Parser<I, O> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  final Parser<I, O> p5;

  final Parser<I, O> p6;

  const Choice6(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6,
      {String? name})
      : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Choice6(
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
    final r1 = p1.fastParse(state);
    if (r1) {
      return r1;
    }

    final r2 = p2.fastParse(state);
    if (r2) {
      return r2;
    }

    final r3 = p3.fastParse(state);
    if (r3) {
      return r3;
    }

    final r4 = p4.fastParse(state);
    if (r4) {
      return r4;
    }

    final r5 = p5.fastParse(state);
    if (r5) {
      return r5;
    }

    final r6 = p6.fastParse(state);
    if (r6) {
      return r6;
    }

    return false;
  }

  @override
  Result<O>? parse(State<I> state) {
    final r1 = p1.parse(state);
    if (r1 != null) {
      return r1;
    }

    final r2 = p2.parse(state);
    if (r2 != null) {
      return r2;
    }

    final r3 = p3.parse(state);
    if (r3 != null) {
      return r3;
    }

    final r4 = p4.parse(state);
    if (r4 != null) {
      return r4;
    }

    final r5 = p5.parse(state);
    if (r5 != null) {
      return r5;
    }

    final r6 = p6.parse(state);
    if (r6 != null) {
      return r6;
    }

    return null;
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O>();
    final input = state.input;
    late AsyncResult<O> r1;
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
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p2.parseAsync(state);
            action = 2;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 2:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p3.parseAsync(state);
            action = 3;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 3:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p4.parseAsync(state);
            action = 4;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 4:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p5.parseAsync(state);
            action = 5;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 5:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p6.parseAsync(state);
            action = 6;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 6:
            if ((result.ok = r1.ok) == true) {
              result.value = r1.value;
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

class Choice7<I, O> extends Parser<I, O> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  final Parser<I, O> p5;

  final Parser<I, O> p6;

  final Parser<I, O> p7;

  const Choice7(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7,
      {String? name})
      : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Choice7(
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
    final r1 = p1.fastParse(state);
    if (r1) {
      return r1;
    }

    final r2 = p2.fastParse(state);
    if (r2) {
      return r2;
    }

    final r3 = p3.fastParse(state);
    if (r3) {
      return r3;
    }

    final r4 = p4.fastParse(state);
    if (r4) {
      return r4;
    }

    final r5 = p5.fastParse(state);
    if (r5) {
      return r5;
    }

    final r6 = p6.fastParse(state);
    if (r6) {
      return r6;
    }

    final r7 = p7.fastParse(state);
    if (r7) {
      return r7;
    }

    return false;
  }

  @override
  Result<O>? parse(State<I> state) {
    final r1 = p1.parse(state);
    if (r1 != null) {
      return r1;
    }

    final r2 = p2.parse(state);
    if (r2 != null) {
      return r2;
    }

    final r3 = p3.parse(state);
    if (r3 != null) {
      return r3;
    }

    final r4 = p4.parse(state);
    if (r4 != null) {
      return r4;
    }

    final r5 = p5.parse(state);
    if (r5 != null) {
      return r5;
    }

    final r6 = p6.parse(state);
    if (r6 != null) {
      return r6;
    }

    final r7 = p7.parse(state);
    if (r7 != null) {
      return r7;
    }

    return null;
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O>();
    final input = state.input;
    late AsyncResult<O> r1;
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
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p2.parseAsync(state);
            action = 2;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 2:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p3.parseAsync(state);
            action = 3;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 3:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p4.parseAsync(state);
            action = 4;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 4:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p5.parseAsync(state);
            action = 5;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 5:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p6.parseAsync(state);
            action = 6;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 6:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p7.parseAsync(state);
            action = 7;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 7:
            if ((result.ok = r1.ok) == true) {
              result.value = r1.value;
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

class Choice8<I, O> extends Parser<I, O> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  final Parser<I, O> p5;

  final Parser<I, O> p6;

  final Parser<I, O> p7;

  final Parser<I, O> p8;

  const Choice8(
      this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7, this.p8,
      {String? name})
      : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Choice8(
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
    final r1 = p1.fastParse(state);
    if (r1) {
      return r1;
    }

    final r2 = p2.fastParse(state);
    if (r2) {
      return r2;
    }

    final r3 = p3.fastParse(state);
    if (r3) {
      return r3;
    }

    final r4 = p4.fastParse(state);
    if (r4) {
      return r4;
    }

    final r5 = p5.fastParse(state);
    if (r5) {
      return r5;
    }

    final r6 = p6.fastParse(state);
    if (r6) {
      return r6;
    }

    final r7 = p7.fastParse(state);
    if (r7) {
      return r7;
    }

    final r8 = p8.fastParse(state);
    if (r8) {
      return r8;
    }

    return false;
  }

  @override
  Result<O>? parse(State<I> state) {
    final r1 = p1.parse(state);
    if (r1 != null) {
      return r1;
    }

    final r2 = p2.parse(state);
    if (r2 != null) {
      return r2;
    }

    final r3 = p3.parse(state);
    if (r3 != null) {
      return r3;
    }

    final r4 = p4.parse(state);
    if (r4 != null) {
      return r4;
    }

    final r5 = p5.parse(state);
    if (r5 != null) {
      return r5;
    }

    final r6 = p6.parse(state);
    if (r6 != null) {
      return r6;
    }

    final r7 = p7.parse(state);
    if (r7 != null) {
      return r7;
    }

    final r8 = p8.parse(state);
    if (r8 != null) {
      return r8;
    }

    return null;
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O>();
    final input = state.input;
    late AsyncResult<O> r1;
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
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p2.parseAsync(state);
            action = 2;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 2:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p3.parseAsync(state);
            action = 3;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 3:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p4.parseAsync(state);
            action = 4;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 4:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p5.parseAsync(state);
            action = 5;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 5:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p6.parseAsync(state);
            action = 6;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 6:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p7.parseAsync(state);
            action = 7;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 7:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p8.parseAsync(state);
            action = 8;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 8:
            if ((result.ok = r1.ok) == true) {
              result.value = r1.value;
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

class Choice9<I, O> extends Parser<I, O> {
  final Parser<I, O> p1;

  final Parser<I, O> p2;

  final Parser<I, O> p3;

  final Parser<I, O> p4;

  final Parser<I, O> p5;

  final Parser<I, O> p6;

  final Parser<I, O> p7;

  final Parser<I, O> p8;

  final Parser<I, O> p9;

  const Choice9(this.p1, this.p2, this.p3, this.p4, this.p5, this.p6, this.p7,
      this.p8, this.p9,
      {String? name})
      : super(name);

  @override
  Parser<I, O> build(ParserBuilder<I> builder) {
    return Choice9(
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
    final r1 = p1.fastParse(state);
    if (r1) {
      return r1;
    }

    final r2 = p2.fastParse(state);
    if (r2) {
      return r2;
    }

    final r3 = p3.fastParse(state);
    if (r3) {
      return r3;
    }

    final r4 = p4.fastParse(state);
    if (r4) {
      return r4;
    }

    final r5 = p5.fastParse(state);
    if (r5) {
      return r5;
    }

    final r6 = p6.fastParse(state);
    if (r6) {
      return r6;
    }

    final r7 = p7.fastParse(state);
    if (r7) {
      return r7;
    }

    final r8 = p8.fastParse(state);
    if (r8) {
      return r8;
    }

    final r9 = p9.fastParse(state);
    if (r9) {
      return r9;
    }

    return false;
  }

  @override
  Result<O>? parse(State<I> state) {
    final r1 = p1.parse(state);
    if (r1 != null) {
      return r1;
    }

    final r2 = p2.parse(state);
    if (r2 != null) {
      return r2;
    }

    final r3 = p3.parse(state);
    if (r3 != null) {
      return r3;
    }

    final r4 = p4.parse(state);
    if (r4 != null) {
      return r4;
    }

    final r5 = p5.parse(state);
    if (r5 != null) {
      return r5;
    }

    final r6 = p6.parse(state);
    if (r6 != null) {
      return r6;
    }

    final r7 = p7.parse(state);
    if (r7 != null) {
      return r7;
    }

    final r8 = p8.parse(state);
    if (r8 != null) {
      return r8;
    }

    final r9 = p9.parse(state);
    if (r9 != null) {
      return r9;
    }

    return null;
  }

  @override
  AsyncResult<O> parseAsync(State<ChunkedData<I>> state) {
    final result = AsyncResult<O>();
    final input = state.input;
    late AsyncResult<O> r1;
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
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p2.parseAsync(state);
            action = 2;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 2:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p3.parseAsync(state);
            action = 3;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 3:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p4.parseAsync(state);
            action = 4;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 4:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p5.parseAsync(state);
            action = 5;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 5:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p6.parseAsync(state);
            action = 6;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 6:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p7.parseAsync(state);
            action = 7;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 7:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p8.parseAsync(state);
            action = 8;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 8:
            if (r1.ok == true) {
              result.value = r1.value;
              result.ok = true;
              input.handler = result.handler;
              return;
            }

            r1 = p9.parseAsync(state);
            action = 9;
            if (r1.ok == null) {
              r1.handler = parse;
              return;
            }

            break;
          case 9:
            if ((result.ok = r1.ok) == true) {
              result.value = r1.value;
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
