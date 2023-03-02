import 'package:app/core/block/menu_block.dart';
import 'package:app/core/clusters/cluster.interface.dart';
import 'package:app/core/clusters/dbscan.dart';
import 'package:app/core/clusters/line_alignment.dart';
import 'package:app/core/menu_engine.dart';
import 'package:app/core/utils/sort.dart';
import 'package:app/core/utils/statics.dart';

enum ClusterType {
  lineAlign,
  dbscan,
  unClustered,
}

enum DataType {
  price,
  menu,
  coupled,
}

class MenuCluster {
  final MenuBlockList clusteredMenuBlockList;
  late final ClusterType clusterType;
  late final DataType dataType;

  int get clusteredCount => clusteredMenuBlockList.length;

  MenuBlockList getSortedMenuBlockByYCoord(MenuBlockList targetBlockList) {
    targetBlockList.sort(
      (blockA, blockB) => ascendingSort(
        blockA.block.tl.y,
        blockB.block.tl.y,
      ),
    );
    return targetBlockList;
  }

  MenuCluster({
    required this.clusteredMenuBlockList,
    required this.clusterType,
    required this.dataType,
  });
}

/// `LineAlign` clustered menu blocks
class LineAlignCluster extends MenuCluster {
  LineAlignCluster({
    required super.clusteredMenuBlockList,
    required super.dataType,
  }) : super(
          clusterType: ClusterType.lineAlign,
        );

  @override
  MenuBlockList get clusteredMenuBlockList =>
      getSortedMenuBlockByYCoord(super.clusteredMenuBlockList);

  num get lineHeight =>
      clusteredMenuBlockList.first.block.tl.y -
      clusteredMenuBlockList.last.block.tl.y;
}

/// `DBSCAN` clustered menu blocks
class DBSCANCluster extends MenuCluster {
  DBSCANCluster({
    required super.clusteredMenuBlockList,
  }) : super(
          clusterType: ClusterType.dbscan,
          dataType: DataType.coupled,
        );

  @override
  MenuBlockList get clusteredMenuBlockList =>
      getSortedMenuBlockByYCoord(super.clusteredMenuBlockList);
}

/// `UnClustered` clustered menu blocks
class UnClustered extends MenuCluster {
  UnClustered({
    required super.clusteredMenuBlockList,
  }) : super(
          clusterType: ClusterType.unClustered,
          dataType: DataType.coupled,
        );
}

class ClusteringEngine {
  late final DBSCAN _$dbscan;
  late final LineAlignment _$lineAlign;
  late final MenuBlockList _originalMenuBlockList;

  /// `LineAlignment` clustering default option
  static const defaultMaximumAngleOfYAxis = 5;

  /// `LineAlignment` clustering default option
  static const defaultMinimumPointOfLine = 2;

  /// `DBSCAN` clustering default option
  static const defaultScanRectSizeRatio = 3;

  /// `DBSCAN` clustering default option
  static const defaultNumberOfCorePointCount = 3;

  /// `Average` of menu blocks height
  late final num blockHeightAvg;

  /// Clustering target
  ///
  /// First value is same as input of `MenuBlockList`
  late MenuBlockList clusterTargetMenuBlockList = _originalMenuBlockList;

  /// `LineAlignment` clustering option
  int? maximumAngleOfYAxis;

  /// `LineAlignment` clustering option
  int? minimumPointOfLine;

  /// `LineAlignment` clustering option
  int? maximumPointGapRatio;

  /// `DBSCAN` clustering option
  int? numberOfCorePointCondition;

  /// `DBSCAN` clustering option
  int? scanRectSizeRatio;

  /// Clustered result of menu blocks
  final List<MenuCluster> menuClusters = [];

  void _initializeClusteringEngines() {
    _$dbscan = DBSCAN(
      clusterTarget: [],
      scanRectSize: scanRectSizeRatio != null
          ? (blockHeightAvg * scanRectSizeRatio!).toInt()
          : (blockHeightAvg * defaultScanRectSizeRatio).toInt(),
      numberOfCorePointCondition:
          numberOfCorePointCondition ?? defaultNumberOfCorePointCount,
    );
    _$lineAlign = LineAlignment(
      clusterTarget: [],
      maximumAngleOfYAxis: maximumAngleOfYAxis ?? defaultMaximumAngleOfYAxis,
      minimumPointOfLine: minimumPointOfLine ?? defaultMinimumPointOfLine,
      maximumPointGap: maximumPointGapRatio != null
          ? (maximumPointGapRatio! * blockHeightAvg).toInt()
          : null,
    );
  }

  ClusteringEngine({
    required MenuBlockList menuBlockList,
    this.maximumPointGapRatio,
    this.maximumAngleOfYAxis,
    this.minimumPointOfLine,
    this.scanRectSizeRatio,
    this.numberOfCorePointCondition,
  }) {
    blockHeightAvg = Statics.avg(
      menuBlockList.map((e) => e.block.height).toList(),
    ).toInt();

    _originalMenuBlockList = menuBlockList;

    _initializeClusteringEngines();
  }

  void _updateMenuClusters(List<MenuCluster> newClusters) {
    menuClusters.addAll(newClusters);
  }

  void _updateClusterTargetMenuBlockList(
    MenuBlockList clusteredBlockList,
  ) {
    final removedClusteredMenuBlockList = clusterTargetMenuBlockList
        .where(
          (block) =>
              clusteredBlockList.any(
                (clusteredBlock) =>
                    MenuBlock.isSameMenuBlock(block, clusteredBlock),
              ) ==
              false,
        )
        .toList();

    clusterTargetMenuBlockList = removedClusteredMenuBlockList;
  }

  void _clusterAndUpdate<Engine extends Cluster<ClusterTarget>, ClusterTarget>({
    required Engine engine,
    required MenuBlockList clusterTargetMenuBlock,
    required List<ClusterTarget> Function(
      MenuBlockList clusterTargetMenuBlockList,
    )
        pickClusterTarget,
    required MenuCluster Function(
      List<MenuBlock> clusterTargetMenuBlockList,
    )
        createClusterInstance,
  }) {
    engine.updateClusterTarget(
      pickClusterTarget(clusterTargetMenuBlock),
    );
    engine.cluster();

    final allClusterTargetMenuBlockList = engine.clusteredIndexList
        .map(
          (clusteredIndexList) => clusteredIndexList
              .map(
                (index) => clusterTargetMenuBlock[index],
              )
              .toList(),
        )
        .toList();

    final clusterInstanceList =
        allClusterTargetMenuBlockList.map(createClusterInstance).toList();

    _updateMenuClusters(clusterInstanceList);

    for (final clusteredBlock in allClusterTargetMenuBlockList) {
      _updateClusterTargetMenuBlockList(clusteredBlock);
    }
  }

  void updateUnClusteredMenuBlockList() {
    _updateMenuClusters([
      UnClustered(
        clusteredMenuBlockList: clusterTargetMenuBlockList,
      )
    ]);
  }

  void lineAlignmentClustering({
    required List<MenuBlock> clusterTargetMenuBlock,
    required DataType dataType,
  }) {
    _clusterAndUpdate(
      engine: _$lineAlign,
      clusterTargetMenuBlock: clusterTargetMenuBlock,
      pickClusterTarget: (clusterTargetMenuBlockList) =>
          clusterTargetMenuBlockList.map((e) => e.block).toList(),
      createClusterInstance: (clusterTargetMenuBlockList) => LineAlignCluster(
        clusteredMenuBlockList: clusterTargetMenuBlockList,
        dataType: dataType,
      ),
    );
  }

  void dbscanClustering({
    required List<MenuBlock> clusterTargetMenuBlock,
  }) {
    _clusterAndUpdate(
      engine: _$dbscan,
      clusterTargetMenuBlock: clusterTargetMenuBlock,
      pickClusterTarget: (clusterTargetMenuBlockList) =>
          clusterTargetMenuBlockList.map((e) => e.block.center).toList(),
      createClusterInstance: (clusterTargetMenuBlockList) => DBSCANCluster(
        clusteredMenuBlockList: clusterTargetMenuBlockList,
      ),
    );
  }

  ///TODO: cluster 함수가 있어야 할까? 고민 후 구현
  // @override
  // void cluster({bool? resetData = false, bool? cluster}) {
  //   void _resetData() {
  //     clusterTargetMenuBlockList = _originalMenuBlockList;
  //     menuClusters.clear();
  //   }

  //   if (resetData == true) {
  //     _resetData();
  //   }

  //   lineAlignmentCluster(
  //     clusterTargetMenuBlock: _originalMenuBlockList
  //         .filter((current, i) => isPriceText(current.text) == false),
  //     dataType: DataType.menu,
  //   );
  //   lineAlignmentCluster(
  //     clusterTargetMenuBlock: _originalMenuBlockList
  //         .filter((current, i) => isPriceText(current.text)),
  //     dataType: DataType.price,
  //   );

  //   dbscanClustering(
  //     clusterTargetMenuBlock: clusterTargetMenuBlockList,
  //   );

  //   updateUnClusteredMenuBlockList();
  // }
}
