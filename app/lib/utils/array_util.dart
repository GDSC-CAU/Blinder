extension Mapper<T> on List<T> {
  /// add current `index` and `tot` on `map` function
  /// ```dart
  /// [1, 2, 3, 4].mapWithIndex((current, i) => i);
  /// ```
  List<R> mapper<R>(
    R Function(T current, int i, List<T> tot) callback,
  ) {
    final List<R> result = [];
    for (int i = 0; i < length; i++) {
      result.add(callback(this[i], i, this));
    }
    return result;
  }
}

extension Folder<T> on List<T> {
  /// add current `index` and `tot` on `fold` function
  /// ```dart
  /// [1, 2, 3, 4].folder(
  ///   0,
  ///   (acc, current, i, tot) {
  ///     final isEven = i % 2 == 0;
  ///     if(isEven) return acc + current;
  ///     return acc;
  ///   }
  /// );
  /// ```
  R folder<R>(
    R initialValue,
    R Function(R acc, T curr, int i, List<T> tot) combine,
  ) {
    var value = initialValue;
    for (int i = 0; i < length; i++) {
      value = combine(value, this[i], i, this);
    }
    return value;
  }
}

extension Filter<T> on List<T> {
  List<T> filter(
    bool Function(T current, int i) filterFunction,
  ) {
    final List<T> result = [];
    for (int i = 0; i < length; i++) {
      if (filterFunction(this[i], i)) {
        result.add(this[i]);
      }
    }
    return result;
  }
}
