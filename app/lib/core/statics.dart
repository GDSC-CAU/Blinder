import 'dart:math';

import 'package:app/utils/array_util.dart';

class Statics {
  Statics();

  static double avg(List<int> numbers) => numbers.isEmpty
      ? 0
      : numbers.reduce((value, element) => value + element) / numbers.length;

  static num std(List<int> numbers) {
    final numbersAvg = avg(numbers);
    final numbersLength = numbers.length;
    return sqrt(
      numbers.isEmpty
          ? 0
          : numbers.reduce(
              (
                value,
                number,
              ) =>
                  value + pow(number - numbersAvg, 2).toInt() ~/ numbersLength,
            ),
    );
  }

  static int getQuartileAt(
    List<int> numbers, {
    required int at,
    int divide = 10,
  }) {
    final numLength = numbers.length;
    final step = numLength ~/ divide;

    final List<int> quartileIndexList = List<int>.filled(numLength, 0).folder(
      [],
      (indexList, curr, i, tot) {
        final quartileIndex = curr + step * (i + 1);
        indexList.add(
          quartileIndex >= numLength ? numLength : quartileIndex,
        );
        return indexList;
      },
    );

    if (at >= quartileIndexList.length) {
      throw Exception(
        "Out of range\nyou should choose index between 0 ~ ${quartileIndexList.length}",
      );
    }

    return numbers[quartileIndexList[at]];
  }
}
