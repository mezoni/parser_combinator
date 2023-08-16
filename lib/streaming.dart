import 'runtime.dart';

abstract class ChunkedData<T> implements Sink<T> {
  void Function()? handler;

  bool Function()? listener;

  bool _isClosed = false;

  int buffering = 0;

  T data;

  int start = 0;

  final T _empty;

  ChunkedData(T empty)
      : data = empty,
        _empty = empty;

  bool get isClosed => _isClosed;

  @override
  void add(T data) {
    if (_isClosed) {
      throw StateError('Chunked data sink already closed');
    }

    if (buffering != 0) {
      this.data = join(this.data, data);
    } else {
      final length = getLength(data);
      start += length;
      this.data = data;
    }

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
      //
    }
  }

  @override
  void close() {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    while (listener != null) {
      final f = listener!;
      if (f()) {
        listener = null;
      }

      while (handler != null) {
        final f = handler!;
        handler = null;
        f();
      }
    }

    if (buffering != 0) {
      throw StateError('On closing, an incomplete buffering was detected');
    }

    final length = getLength(data);
    if (length != 0) {
      data = _empty;
    }
  }

  int getLength(T data);

  void handle(void Function()? handler) {
    this.handler = handler;
  }

  T join(T data1, T data2);

  void listen(bool Function()? listener) {
    this.listener = listener;
  }
}

class StringReaderChunkedData extends ChunkedData<StringReader> {
  StringReaderChunkedData() : super(StringReader(''));

  @override
  int getLength(StringReader data) => data.length;

  @override
  StringReader join(StringReader data1, StringReader data2) =>
      data1.length != 0 ? StringReader(data1.source! + data2.source!) : data2;
}
