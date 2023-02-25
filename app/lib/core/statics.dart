import 'dart:math';

import 'package:app/utils/array.dart';

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

  /// get side step points
  /// ```dart
  /// final steps = Statics.getSideStepPoint(...numbers);
  /// final firstStep = steps["first"];
  /// final lastStep = steps["last"];
  /// ```
  static Map<String, int?> getSideStepPoint(
    List<int> numbers,
  ) {
    numbers.sort();
    final numbersDiff = numbers.folder<List<int>>(
      [],
      (diffs, number, i, tot) {
        if (i == tot.length - 1) {
          return diffs;
        }
        final nextNumber = tot[i + 1];
        final diff = nextNumber - number;
        if (diff == 0) {
          return diffs;
        }
        diffs.add(diff);
        return diffs;
      },
    );
    final avgOfNumberDiff = avg(numbersDiff);
    final stdOfNumberDiff = std(numbersDiff);

    final stepPointList = numbers.folder<List<int>>(
      [],
      (pointList, number, currentIndex, tot) {
        if (currentIndex == tot.length - 1) return pointList;

        final nextNumber = tot[currentIndex + 1];
        final currentDiff = nextNumber - number;

        final isStepIn = currentDiff <= avgOfNumberDiff + stdOfNumberDiff / 2;
        if (isStepIn) return pointList;

        pointList.add(currentIndex + 1);
        return pointList;
      },
    );

    if (stepPointList.isEmpty) {
      return {
        "first": null,
        "last": null,
      };
    }
    if (stepPointList.length == 1) {
      final isClosedToFirst = stepPointList.first <= numbers.length / 2;
      return isClosedToFirst
          ? {
              "first": stepPointList.first - 1,
              "last": null,
            }
          : {
              "first": null,
              "last": stepPointList.first - 1,
            };
    }

    final isBothClosedToFirst = stepPointList.first <= numbers.length / 2 &&
        stepPointList.last <= numbers.length / 2;

    if (isBothClosedToFirst) {
      return {
        "first": stepPointList.first - 1,
        "last": null,
      };
    }

    final isBothClosedToLast = stepPointList.first > numbers.length / 2 &&
        stepPointList.last > numbers.length / 2;

    if (isBothClosedToLast) {
      return {
        "first": null,
        "last": stepPointList.last,
      };
    }

    return {
      "first": stepPointList.first - 1,
      "last": stepPointList.last,
    };
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
