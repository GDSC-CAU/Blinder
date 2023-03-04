import 'dart:math';

import 'package:app/core/block/block.dart';
import 'package:app/core/clusters/cluster.interface.dart';
import 'package:app/core/utils/math.dart';
import 'package:app/core/utils/statics.dart';
import 'package:app/utils/array.dart';

class LineAlignmentSegment {
  final Set<int> alignedIndexList;
  final LineAlignedDirection alignedDirection;

  LineAlignmentSegment({
    required this.alignedIndexList,
    required this.alignedDirection,
  });
}

/// Aligned Direction of line
///
/// `◀️ left` `center ⬇️` `right ▶`
enum LineAlignedDirection {
  left,
  center,
  right,
}

class LineAlignment implements Cluster<Block> {
  /// Maximum gap of two `points`
  final int? maximumPointGap;

  /// Maximum `Angle(Degree)` with `y` axis at `point` to `point` line
  final int maximumAngleOfYAxis;

  /// Minimum number of point number of **_clustered line composition_**
  final int minimumPointOfLine;

  @override
  void updateClusterTarget(List<Block> newClusterTarget) {
    lineAlignmentSegments.clear();
    clusterTarget.clear();
    clusterTarget.addAll(newClusterTarget);
  }

  /// List of `Block`
  @override
  final List<Block> clusterTarget;

  /// **Clustered result** of line segments
  ///
  /// - Returns **`[[<left>], [<center>], [<right>]]`**
  final List<List<LineAlignmentSegment>> lineAlignmentSegments = [];

  /// **Clustered result** of line segments
  ///
  /// - Pick one of **`[[<left>], [<center>], [<right>]]`**
  /// - Get largest set of them
  List<LineAlignmentSegment> get lineAlignmentSegment {
    final countOfClusteredIndex = lineAlignmentSegments.fold<List<int>>(
      [],
      (countList, segments) {
        if (segments.isEmpty) {
          countList.add(0);
          return countList;
        }
        final clusteredCount = segments
            .map(
              (segment) => segment.alignedIndexList.length,
            )
            .reduce(
              (totIndexCount, indexListLength) =>
                  totIndexCount + indexListLength,
            );

        countList.add(clusteredCount);
        return countList;
      },
    );
    final maxAlignedIndex = Math.findMaxIndexList(countOfClusteredIndex);
    if (maxAlignedIndex.length == 1) {
      return lineAlignmentSegments[maxAlignedIndex.first];
    }

    final countOfClusteredSection = lineAlignmentSegments
        .map(
          (segments) => segments.length,
        )
        .toList();
    final maxSectionIndex = Math.findMaxIndex(countOfClusteredSection);

    return lineAlignmentSegments[maxSectionIndex];
  }

  List<Coord> get _leftCoordList => clusterTarget.map((e) => e.tl).toList();
  List<Coord> get _centerCoordList =>
      clusterTarget.map((e) => e.center).toList();
  List<Coord> get _rightCoordList => clusterTarget.map((e) => e.tr).toList();

  List<IndexList> get allClusteredIndexList => lineAlignmentSegments
      .map(
        (e) => e.fold<IndexList>(
          [],
          (lineAlignedIndexList, segment) {
            lineAlignedIndexList.addAll(segment.alignedIndexList);
            return lineAlignedIndexList;
          },
        ),
      )
      .toList();

  @override
  List<IndexList> get clusteredIndexList => lineAlignmentSegment
      .map(
        (e) => e.alignedIndexList.toList(),
      )
      .toList();

  LineAlignment({
    required this.clusterTarget,
    required this.maximumAngleOfYAxis,
    required this.minimumPointOfLine,
    this.maximumPointGap,
  });

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
                latestClustered.alignedIndexList.map((index) => tot[index]).map(
              (lineCoord) {
                /// 점 중에 하나라도 isTwoPointAligned를 만족하면 cluster에 포함시킴
                final isTwoPointAligned = _isTwoPointAligned(
                  first: lineCoord,
                  second: iterCoord,
                );

                final fullCheckyInYDirection = maximumPointGap == null;
                if (fullCheckyInYDirection) {
                  return isTwoPointAligned;
                }
                return isTwoPointAligned &&
                    lineCoord.distanceTo(iterCoord).toInt() <= maximumPointGap!;
              },
            ).any((isAligned) => isAligned);

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
  ///
  /// `maximumAngleOfYAxis` - Maximum `Angle(Degree)` with `y` axis at `point` to `point` line
  ///
  /// Search until all price is being placed
  @override
  void cluster({
    int? maximumAngleOfYAxis,
    int? maximumPointGap,
  }) {
    maximumPointGap = maximumPointGap;
    maximumAngleOfYAxis = maximumAngleOfYAxis;

    final iterCoordsList = [
      _leftCoordList,
      _centerCoordList,
      _rightCoordList,
    ];

    for (var i = 0; i < iterCoordsList.length; i++) {
      _clusterCoordsIntoLines(
        coordList: iterCoordsList[i],
        alignedDirection: LineAlignedDirection.values[i],
      );
    }
  }
}
