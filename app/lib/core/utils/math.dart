import 'package:app/utils/array.dart';

class Math {
  const Math();
  static int findMaxIndex<T extends num>(
    List<T> numbers,
  ) =>
      numbers.folder<int>(
        0,
        (maxIndex, currentNumber, index, tot) =>
            currentNumber > tot[maxIndex] ? index : maxIndex,
      );

  static int findMinIndex<T extends num>(
    List<T> numbers,
  ) =>
      numbers.folder<int>(
        0,
        (minIndex, currentNumber, index, tot) =>
            currentNumber < tot[minIndex] ? index : minIndex,
      );

  static T getMinMaxDiff<T extends num>(
    List<T> numbers,
  ) =>
      numbers[findMaxIndex(numbers)] - numbers[findMinIndex(numbers)] as T;

  static List<int> findMaxIndexList<T extends num>(List<T> numbers) {
    if (numbers.isEmpty) return [];
    final max = numbers[findMaxIndex(numbers)];

    return numbers.folder<List<int>>(
      [],
      (maxIndexList, number, i, tot) =>
          number == max ? [...maxIndexList, i] : maxIndexList,
    );
  }

  static List<int> findMinIndexList<T extends num>(List<T> numbers) {
    if (numbers.isEmpty) return [];
    final min = numbers[findMaxIndex(numbers)];

    return numbers.folder<List<int>>(
      [],
      (minIndexList, number, i, tot) =>
          number == min ? [...minIndexList, i] : minIndexList,
    );
  }
}
