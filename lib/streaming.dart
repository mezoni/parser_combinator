class ChunkedData<T> implements Sink<T> {
  void Function()? handler;

  bool Function()? listener;

  bool _isClosed = false;

  List<T> buffer = [];

  int buffering = 0;

  int index0 = 0;

  int index1 = 0;

  int index2 = 0;

  int start = 0;

  bool get isClosed => _isClosed;

  @override
  void add(T data) {
    if (_isClosed) {
      throw StateError('Chunked data sink already closed');
    }

    if (buffering == 0) {
      start += buffer.length;
      buffer = [];
    }

    buffer.add(data);
    if (listener != null) {
      final f = listener!;
      if (f()) {
        listener = null;
      }
    }

    while (handler != null) {
      if (buffering == 0 && buffer.isNotEmpty && index1 > 0) {
        buffer.removeRange(0, index1);
        start += index1;
        index1 = 0;
      }

      final f = handler!;
      handler = null;
      f();
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
  }

  void handle(void Function()? handler) {
    this.handler = handler;
  }

  void listen(bool Function()? listener) {
    this.listener = listener;
  }
}
