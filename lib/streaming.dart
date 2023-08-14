class ChunkedData<T> implements Sink<T> {
  void Function()? handler;

  bool Function()? listener;

  bool _isClosed = false;

  List<T> buffer = [];

  int buffering = 0;

  int index0 = 0;

  int index1 = 0;

  int start = 0;

  bool get isClosed => _isClosed;

  @override
  void add(T data) {
    if (_isClosed) {
      throw StateError('Chunked data sink already closed');
    }

    buffer.add(data);
    if (listener != null) {
      final f = listener!;
      if (f()) {
        listener = null;
      }
    }

    while (handler != null) {
      final f = handler!;
      handler = null;
      f();
    }

    if (buffering == 0) {
      start += buffer.length;
      buffer = [];
    }
  }

  @override
  void close() {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    if (listener != null) {
      final f = listener!;
      if (f()) {
        listener = null;
      }
    }

    while (handler != null) {
      final f = handler!;
      handler = null;
      f();
    }

    if (buffering != 0) {
      throw StateError('On closing, an incomplete buffering was detected');
    }

    if (buffer.isNotEmpty) {
      buffer = [];
    }
  }

  void handle(void Function()? handler) {
    this.handler = handler;
  }

  void listen(bool Function()? listener) {
    this.listener = listener;
  }
}

class ChunkedDataParser {
  static void parse<T>(
    ChunkedData<T> input, {
    required int Function(T chunk) getLength,
    required int? Function(T chunk, int index) onData,
    required void Function() onClose,
    required void Function() onError,
  }) {
    final buffer = input.buffer;
    final index0 = input.index0;
    final index1 = input.index1;
    input.buffering++;
    bool parse() {
      if (input.index0 < input.start) {
        input.buffering--;
        input.index0 = index0;
        input.index1 = index1;
        onError();
        return true;
      }

      var index = input.index0 - input.start;
      while (index < buffer.length) {
        final chunk = buffer[index];
        if (input.index1 >= getLength(chunk)) {
          index++;
          input.index0++;
          input.index1 = 0;
          continue;
        }

        final count = onData(chunk, input.index1);
        if (count == null) {
          input.buffering--;
          input.index0 = index0;
          input.index1 = index1;
          return true;
        }

        if (count > 0) {
          input.index1 += count;
        } else {
          input.buffering--;
          input.index1 += -count;
          return true;
        }
      }

      if (input.isClosed) {
        input.buffering--;
        input.index0 = index0;
        input.index1 = index1;
        onClose();
        return true;
      }

      input.listen(parse);
      return false;
    }

    parse();
  }
}
