class ChunkedData<T> implements Sink<T> {
  void Function()? handler;

  bool Function()? listener;

  bool _isClosed = false;

  List<T> buffer = [];

  int buffering = 0;

  int count = 0;

  int position = 0;

  int index = 0;

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

  void trackCount(int count) {
    if (this.count < count) {
      this.count = count;
    }
  }
}
