import 'dart:math';

import 'package:app/core/block/block.dart';
import 'package:app/core/utils/sort.dart';
import 'package:app/core/utils/statics.dart';
import 'package:app/utils/array.dart';

typedef IndexList = List<int>;

class LineAlignmentSegment {
  final Set<int> alignedIndexList;
  final LineAlignedDirection alignedDirection;

  static int getDiffOfMinMax(List<num> numbers) {
    final minFirstMaxLast = numbers.fold<List<num>>(
      [],
      (previousValue, element) {
        previousValue.first = min(element, previousValue.first);
        previousValue.last = max(element, previousValue.last);
        return previousValue;
      },
    );
    return (minFirstMaxLast.last - minFirstMaxLast.first).toInt();
  }

  LineAlignmentSegment({
    required this.alignedIndexList,
    required this.alignedDirection,
  });
}

class AbstractedLine {
  final List<Coord> coordList;

  AbstractedLine({
    required this.coordList,
  }) {
    coordList.sort(
      (a, b) => ascendingSort(a.y, b.y),
    );
  }
}

/// Aligned Direction of line
///
/// `◀️ left` `center ⬇️` `right ▶`
enum LineAlignedDirection {
  left,
  center,
  right,
}

class LineAlignment {
  /// Maximum gap of two `points`
  final int maximumPointGap;

  /// Maximum `Angle(Degree)` with `y` axis at `point` to `point` line
  final int maximumAngleOfYAxis;

  /// Minimum number of point number of **_clustered line composition_**
  final int minimumPointOfLine;

  final List<Block> _blockList;

  /// **Clustered result** of line segments
  ///
  /// - Returns **`[[<left>], [<center>], [<right>]]`**
  ///
  /// - Deduplicated
  final List<List<LineAlignmentSegment>> lineAlignmentSegments = [];

  List<Coord> get _leftCoordList => _blockList.map((e) => e.tl).toList();
  List<Coord> get _centerCoordList => _blockList.map((e) => e.center).toList();
  List<Coord> get _rightCoordList => _blockList.map((e) => e.tr).toList();

  List<IndexList> get lineAlignmentSegmentsIndexList => lineAlignmentSegments
      .map(
        (e) => e.fold<IndexList>(
          [],
          (previousValue, element) {
            previousValue.addAll(element.alignedIndexList);
            previousValue.sort();
            return previousValue;
          },
        ),
      )
      .toList();

  LineAlignment({
    required List<Block> blockList,
    required this.maximumPointGap,
    required this.maximumAngleOfYAxis,
    required this.minimumPointOfLine,
  }) : _blockList = blockList;

  void _updateLineAlignmentSegments(
    List<LineAlignmentSegment> newSegments, {
    required bool shouldClearBefore,
  }) {
    if (shouldClearBefore) lineAlignmentSegments.clear();
    lineAlignmentSegments.add(newSegments);
  }

  List<int> _getSlopeList(
    List<Coord> coords,
    num Function(
      Coord coord,
      Coord nextCoord,
    )
        getSlopeBetween,
  ) {
    final slopeList = coords.folder<List<int>>(
      [],
      (slopeList, coord, i, tot) {
        if (i == coords.length - 1) {
          return slopeList;
        }
        final nextCoord = coords[i + 1];
        final slopeBetween = getSlopeBetween(coord, nextCoord);
        slopeList.add(slopeBetween.toInt());
        return slopeList;
      },
    );
    return slopeList;
  }

  bool _getLineAlignedStateBySlopeList(
    List<int> slopeList, {
    num maxSlopeStd = 0.5,
    num maxSlopeAvg = 1,
  }) {
    final std = Statics.std(slopeList);
    final avg = Statics.avg(slopeList).abs();

    final isAlignedEnough = std <= maxSlopeStd && avg <= maxSlopeAvg;

    return isAlignedEnough;
  }

  bool _isTwoPointAligned({
    required Coord first,
    required Coord second,
  }) {
    final distance = first.distanceTo(second);
    if (distance > maximumPointGap) {
      return false;
    }

    const radToDegree = 360 / (2 * pi);

    final angleWithYAxis = acos(
          (second.y - first.y).abs() / distance,
        ) *
        radToDegree;

    return angleWithYAxis <= maximumAngleOfYAxis;
  }

  void _clusterCoordsIntoLines({
    required List<Coord> coordList,
    required LineAlignedDirection alignedDirection,
  }) {
    final clusteredIndexList = <int>{};
    final clusteredLineList = coordList.folder<List<LineAlignmentSegment>>(
      [],
      (savedClusteredLineList, targetCoord, currentI, _) {
        if (clusteredIndexList.contains(currentI)) {
          return savedClusteredLineList;
        }

        final clusteredLine = coordList.folder<List<LineAlignmentSegment>>(
          [
            LineAlignmentSegment(
              alignedIndexList: <int>{currentI},
              alignedDirection: alignedDirection,
            )
          ],
          (clusteredIterations, iterCoord, iterI, tot) {
            /// skip self
            if (currentI == iterI) {
              return clusteredIterations;
            }

            /// skip duplicated iteration
            if (clusteredIndexList.contains(iterI)) {
              return clusteredIterations;
            }

            final latestClustered = clusteredIterations.last;
            final isEachPointAlignedByDegreeCondition =
                latestClustered.alignedIndexList
                    .map((i) => tot[i])
                    .map(
                      (lineCoord) => _isTwoPointAligned(
                        first: lineCoord,
                        second: iterCoord,
                      ),
                    )
                    .any((isAligned) => isAligned == true);

            if (isEachPointAlignedByDegreeCondition == false) {
              return clusteredIterations;
            }

            final newAlignedIndexList = <int>{};
            newAlignedIndexList.addAll(latestClustered.alignedIndexList);
            newAlignedIndexList.add(iterI);

            clusteredIndexList.add(iterI);

            final newClusteredLineSegment = LineAlignmentSegment(
              alignedIndexList: newAlignedIndexList,
              alignedDirection: alignedDirection,
            );

            final newLineSlopeList = _getSlopeList(
              newClusteredLineSegment.alignedIndexList
                  .map((i) => tot[i])
                  .toList(),
              (coord, nextCoord) => (nextCoord.y - coord.y) == 0
                  ? 0
                  : (nextCoord.x - coord.x) / (nextCoord.y - coord.y),
            );
            final isNewPointAligned =
                _getLineAlignedStateBySlopeList(newLineSlopeList);

            if (isNewPointAligned) {
              clusteredIterations.add(newClusteredLineSegment);
            }

            return clusteredIterations;
          },
        );

        savedClusteredLineList.add(clusteredLine.last);
        return savedClusteredLineList;
      },
    );

    final filteredByPointNumber = clusteredLineList.filter(
      (clustered, _) => clustered.alignedIndexList.length >= minimumPointOfLine,
    );

    _updateLineAlignmentSegments(
      filteredByPointNumber,
      shouldClearBefore: false,
    );
  }

  /// Cluster data
  void cluster() {
    final iterCoordsList = [
      _leftCoordList,
      _centerCoordList,
      _rightCoordList,
    ];

    final alreadyClusteredIndexList = <int>{};

    for (var i = 0; i < iterCoordsList.length; i++) {
      final coordListToIter = iterCoordsList[i].filter(
        (current, i) => alreadyClusteredIndexList.contains(i) == false,
      );

      _clusterCoordsIntoLines(
        coordList: coordListToIter,
        alignedDirection: LineAlignedDirection.values[i],
      );

      final clusteredIndexList = lineAlignmentSegments.fold(<int>{}, (
        indexList,
        currCluster,
      ) {
        final currClustersIndex = currCluster.fold(
          <int>{},
          (indexList, element) {
            indexList.addAll(element.alignedIndexList);
            return indexList;
          },
        );
        indexList.addAll(currClustersIndex);
        return indexList;
      });
      alreadyClusteredIndexList.addAll(clusteredIndexList);
    }
  }
}
