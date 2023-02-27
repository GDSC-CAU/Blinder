import 'dart:math';

import 'package:app/utils/array.dart';

class DensityRectSection<T extends Point> {
  final T corePoint;
  final int corePointIndex;
  final Set<int> borderPointIndexList;

  DensityRectSection({
    required this.corePoint,
    required this.corePointIndex,
    required this.borderPointIndexList,
  });

  @override
  String toString() =>
      "\n{ \n    core: $corePoint, \n    borderIndex: $borderPointIndexList \n}";
}

typedef IndexList = List<int>;
typedef DensityRectSectionList<T extends Point> = List<DensityRectSection<T>>;

class DBSCAN<T extends Point> {
  /// Square scan section area
  final int scanRectSize;

  /// Condition of core point
  final int numberOfCorePointCondition;
  final List<T> _centerPointList;
  final DensityRectSectionList<T> densityRectSections = [];

  /// List of index list of each clustered section
  List<IndexList> get clusteredDensitySectionIndexList =>
      densityRectSections.map<IndexList>(
        (section) {
          final totIndexSet = <int>{};
          totIndexSet.addAll(section.borderPointIndexList);
          totIndexSet.add(section.corePointIndex);

          final totIndexList = totIndexSet.toList();
          totIndexList.sort();
          return totIndexList;
        },
      ).toList();

  /// Index list of noise points
  IndexList get noisePointIndexList {
    final totalClusteredIndexList = clusteredDensitySectionIndexList.fold(
      <int>{},
      (totSectionIndexList, sectionIndexList) {
        totSectionIndexList.addAll(sectionIndexList);
        return totSectionIndexList;
      },
    );
    return List.generate(
      _centerPointList.length,
      (index) => index,
    ).filter(
      (index, i) => totalClusteredIndexList.contains(index) == false,
    );
  }

  DBSCAN({
    required List<T> centerPointList,
    required this.scanRectSize,
    this.numberOfCorePointCondition = 3,
  }) : _centerPointList = centerPointList;

  void _updateDensityRectSections(
    DensityRectSectionList<T> newSections, {
    required bool shouldClearBefore,
  }) {
    if (shouldClearBefore) densityRectSections.clear();
    densityRectSections.addAll(newSections);
  }

  bool _isTargetCoordInCenterRectBoundary({
    required Point targetCoord,
    required Point centerCoord,
  }) {
    final coordDiff = centerCoord - targetCoord;
    final isInBoundary = coordDiff.x.abs() <= scanRectSize / 2 &&
        coordDiff.y.abs() <= scanRectSize / 2;
    return isInBoundary;
  }

  void _divideSectionByDensity() {
    final clusteredSectionList =
        _centerPointList.folder<DensityRectSectionList<T>>(
      [],
      (clusteredSections, currPoint, pointI, tot) {
        final Set<int> borderPointIndexList = tot.folder<Set<int>>(
          <int>{},
          (borderPoints, targetCoord, distI, tot) {
            final isSelf = pointI == distI;
            if (isSelf) return borderPoints;

            if (_isTargetCoordInCenterRectBoundary(
              targetCoord: targetCoord,
              centerCoord: currPoint,
            )) {
              borderPoints.add(distI);
              return borderPoints;
            }

            return borderPoints;
          },
        );

        final isCorePoint =
            borderPointIndexList.length >= numberOfCorePointCondition;
        if (isCorePoint) {
          clusteredSections.add(
            DensityRectSection(
              corePoint: currPoint,
              corePointIndex: pointI,
              borderPointIndexList: borderPointIndexList,
            ),
          );
          return clusteredSections;
        }
        return clusteredSections;
      },
    );

    _updateDensityRectSections(
      clusteredSectionList,
      shouldClearBefore: densityRectSections.isNotEmpty,
    );
  }

  num _getTotalDistanceFromCoreToBorders({
    required Point corePoint,
    required List<Point> borderPoints,
  }) =>
      borderPoints.fold(
        0,
        (totalDistance, borderPoint) =>
            totalDistance + corePoint.distanceTo(borderPoint),
      );

  void _mergeDensityRectSections() {
    DensityRectSectionList<T> mergeSectionsUntilDivided(
      DensityRectSectionList<T> mergedDensitySections,
    ) {
      final Set<int> _mergedIndex = {};

      final mergedDensitySectionsByCorePoint =
          mergedDensitySections.folder<DensityRectSectionList<T>>(
        [],
        (mergedDensitySections, currentSection, currentI, tot) {
          if (currentI == tot.length - 1) return mergedDensitySections;
          if (_mergedIndex.contains(currentI)) {
            return mergedDensitySections;
          }

          final mergedCurrentSection = tot.folder<DensityRectSectionList<T>>(
            /// set base target as currentSection
            [currentSection],
            (merged, section, iterI, tot) {
              if (currentI == iterI) return merged;

              final latestMergedSection = merged.last;

              if (latestMergedSection.corePoint.distanceTo(
                    section.corePoint,
                  ) >
                  scanRectSize / 2) {
                return merged;
              }

              final mergedBorderPointList = <int>{};
              mergedBorderPointList.addAll(
                latestMergedSection.borderPointIndexList,
              );
              mergedBorderPointList.addAll(
                section.borderPointIndexList,
              );

              final isLatestMergedSectionConsideredAsCore =
                  _getTotalDistanceFromCoreToBorders(
                        corePoint: latestMergedSection.corePoint,
                        borderPoints: latestMergedSection.borderPointIndexList
                            .map(
                              (e) => _centerPointList[e],
                            )
                            .toList(),
                      ) <
                      _getTotalDistanceFromCoreToBorders(
                        corePoint: section.corePoint,
                        borderPoints: section.borderPointIndexList
                            .map(
                              (e) => _centerPointList[e],
                            )
                            .toList(),
                      );

              final mergedSection = DensityRectSection(
                corePoint: isLatestMergedSectionConsideredAsCore
                    ? latestMergedSection.corePoint
                    : section.corePoint,
                corePointIndex: isLatestMergedSectionConsideredAsCore
                    ? latestMergedSection.corePointIndex
                    : section.corePointIndex,
                borderPointIndexList: mergedBorderPointList,
              );

              _mergedIndex.add(iterI);

              merged.add(mergedSection);

              return merged;
            },
          ).last;

          mergedDensitySections.add(mergedCurrentSection);
          return mergedDensitySections;
        },
      );

      final isMergeNotCompleted = mergedDensitySectionsByCorePoint
          .mapper(
            (currPoint, currI, _) =>
                mergedDensitySectionsByCorePoint.mapper<bool>(
              (eachPoint, iterI, _) {
                if (iterI == currI) return true;
                final coreDistance =
                    currPoint.corePoint.distanceTo(eachPoint.corePoint);
                return (coreDistance > scanRectSize / 2) &&
                    (coreDistance != 0.0);
              },
            ).any((isMerged) => isMerged == false),
          )
          .any((shouldMergeMore) => shouldMergeMore == true);

      if (isMergeNotCompleted) {
        return mergeSectionsUntilDivided(mergedDensitySectionsByCorePoint);
      } else {
        return mergedDensitySectionsByCorePoint;
      }
    }

    final mergedDensityRectSections =
        mergeSectionsUntilDivided(densityRectSections);

    _updateDensityRectSections(
      mergedDensityRectSections,
      shouldClearBefore: true,
    );
  }

  /// Cluster data by given `scanRectSize`
  void cluster() {
    _divideSectionByDensity();
    _mergeDensityRectSections();
  }
}
