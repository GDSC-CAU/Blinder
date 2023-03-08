import 'package:app/core/block/block.dart';
import 'package:app/core/block/menu_block.dart';
import 'package:app/core/clusters/cluster.interface.dart';
import 'package:app/core/clusters/dbscan.dart';
import 'package:app/core/clusters/line_alignment.dart';
import 'package:app/core/menu_engine.dart';
import 'package:app/core/utils/sort.dart';
import 'package:app/core/utils/statics.dart';
import 'package:app/utils/array.dart';
import 'package:app/utils/text.dart';

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
  DataType get dataType {
    final priceTextCount = clusteredMenuBlockList
        .filter((current, i) => isPriceText(current.text))
        .length;

    final isPriceOnly = priceTextCount == clusteredMenuBlockList.length;
    final isMenuOnly = priceTextCount == 0;

    if (isPriceOnly) return DataType.price;
    if (isMenuOnly) return DataType.menu;
    return DataType.coupled;
  }

  int get clusteredCount => clusteredMenuBlockList.length;

  MenuBlockList _getSortedMenuBlockByYCoord(MenuBlockList targetBlockList) {
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
  });
}

/// `LineAlign` clustered menu blocks
class LineAlignCluster extends MenuCluster {
  LineAlignCluster({
    required super.clusteredMenuBlockList,
  }) : super(
          clusterType: ClusterType.lineAlign,
        );

  @override
  MenuBlockList get clusteredMenuBlockList =>
      _getSortedMenuBlockByYCoord(super.clusteredMenuBlockList);

  Coord get startPoint => clusteredMenuBlockList.first.block.center;
  Coord get endPoint => clusteredMenuBlockList.last.block.center;
  Coord get middlePoint => Coord(
        x: (startPoint.x + endPoint.x) / 2,
        y: (startPoint.y + endPoint.y) / 2,
      );

  num get lineHeight => endPoint.y - startPoint.y;
}

/// `DBSCAN` clustered menu blocks
class DBSCANCluster extends MenuCluster {
  DBSCANCluster({
    required super.clusteredMenuBlockList,
  }) : super(
          clusterType: ClusterType.dbscan,
        );

  @override
  MenuBlockList get clusteredMenuBlockList =>
      _getSortedMenuBlockByYCoord(super.clusteredMenuBlockList);
}

/// `UnClustered` clustered menu blocks
class UnClustered extends MenuCluster {
  UnClustered({
    required super.clusteredMenuBlockList,
  }) : super(
          clusterType: ClusterType.unClustered,
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
  late num blockHeightAvg;

  /// `Average` of menu blocks width
  late num blockWidthAvg;

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

  List<ClusterType> _getSpecificClusters<ClusterType extends MenuCluster>() =>
      menuClusters.fold<List<ClusterType>>(
        [],
        (accCluster, cluster) {
          if (cluster is ClusterType) {
            accCluster.add(cluster);
          }
          return accCluster;
        },
      );

  List<LineAlignCluster> get lineAlignmentClusters =>
      _getSpecificClusters<LineAlignCluster>();

  List<DBSCANCluster> get dbscanClusters =>
      _getSpecificClusters<DBSCANCluster>();

  List<UnClustered> get unClustered => _getSpecificClusters<UnClustered>();

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

  void _updateBlockGeometryStatics(MenuBlockList targetMenuBlockList) {
    blockHeightAvg = Statics.avg(
      targetMenuBlockList.map((e) => e.block.height).toList(),
    ).toInt();
    blockWidthAvg = Statics.avg(
      targetMenuBlockList.map((e) => e.block.width).toList(),
    ).toInt();
  }

  ClusteringEngine({
    required MenuBlockList menuBlockList,
    this.maximumPointGapRatio,
    this.maximumAngleOfYAxis,
    this.minimumPointOfLine,
    this.scanRectSizeRatio,
    this.numberOfCorePointCondition,
  }) {
    _originalMenuBlockList = menuBlockList;
    _updateBlockGeometryStatics(menuBlockList);
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
  }) {
    _clusterAndUpdate(
      engine: _$lineAlign,
      clusterTargetMenuBlock: clusterTargetMenuBlock,
      pickClusterTarget: (clusterTargetMenuBlockList) =>
          clusterTargetMenuBlockList.map((e) => e.block).toList(),
      createClusterInstance: (clusterTargetMenuBlockList) => LineAlignCluster(
        clusteredMenuBlockList: clusterTargetMenuBlockList,
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

  void clearClusteredResult() {
    clusterTargetMenuBlockList = _originalMenuBlockList;
    menuClusters.clear();

    _$dbscan.updateClusterTarget([]);
    _$dbscan.updateClusterTarget([]);
  }

  void updateMenuBlockList(MenuBlockList newMenuBlockList) {
    if (_originalMenuBlockList.isNotEmpty) _originalMenuBlockList.clear();
    _originalMenuBlockList.addAll(newMenuBlockList);

    _updateBlockGeometryStatics(newMenuBlockList);

    clearClusteredResult();
  }
}
