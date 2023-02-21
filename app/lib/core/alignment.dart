import 'package:app/core/menu_parser.dart';
import 'package:app/core/statics.dart';
import 'package:app/core/text_rect_block.dart';
import 'package:app/utils/array_util.dart';

enum RowAlignmentDirection {
  left,
  center,
  right,
}

enum ColAlignmentDirection {
  top,
  middle,
  bottom,
}

class Alignment {
  const Alignment();

  static double _getSlope({
    required double x1,
    required double x2,
    required double y1,
    required double y2,
  }) =>
      (y2 - y1) / (x2 - x1);

  static List<double> _getSlopeList(
    List<Coord> coords,
    double Function(
      Coord coord,
      Coord nextCoord,
    )
        getSlopeBetween,
  ) {
    final slopeList = coords.folder<List<double>>(
      [],
      (slopeList, coord, i, tot) {
        if (i == coords.length) {
          return slopeList;
        }
        final nextCoord = coords[i + 1];
        final slopeBetween = getSlopeBetween(coord, nextCoord);
        slopeList.add(slopeBetween.toDouble());
        return slopeList;
      },
    );
    return slopeList;
  }

  static bool _getAlignedStateByCoordList(
    List<int> slopeList, {
    double stdTolerance = 0.5,
    double avgTolerance = 2,
  }) {
    final std = Statics.std(slopeList);
    final avg = Statics.avg(slopeList).abs();

    final isAlignedEnough = std <= stdTolerance && avg <= avgTolerance;

    return isAlignedEnough;
  }

  static RowAlignmentDirection getRowAlignedDirection(
    MenuRectBlockList menuRectBlocks,
  ) {
    final isLeftAligned = getRowAlignmentState(
      menuRectBlocks,
      RowAlignmentDirection.left,
    );

    if (isLeftAligned) return RowAlignmentDirection.left;
    final isRightAligned = getRowAlignmentState(
      menuRectBlocks,
      RowAlignmentDirection.right,
    );
    if (isRightAligned) return RowAlignmentDirection.right;

    return RowAlignmentDirection.center;
  }

  static bool getRowAlignmentState(
    MenuRectBlockList menuRectBlocks,
    RowAlignmentDirection rowAlign,
  ) {
    final testRowCoordList = _getRowTestCoordList(menuRectBlocks, rowAlign);
    final slopeList = _getSlopeList(
      testRowCoordList,
      (coord, nextCoord) => _getSlope(
        x1: coord.y.toDouble(),
        y1: coord.x.toDouble(),
        x2: nextCoord.y.toDouble(),
        y2: nextCoord.x.toDouble(),
      ),
    )
        .map(
          (e) => e.toInt(),
        )
        .toList();

    return _getAlignedStateByCoordList(slopeList);
  }

  static ColAlignmentDirection getColAlignedDirection(
    MenuRectBlockList menuRectBlocks,
  ) {
    final isBottomAligned = getColAlignmentState(
      menuRectBlocks,
      ColAlignmentDirection.bottom,
    );

    if (isBottomAligned) return ColAlignmentDirection.bottom;

    final isTopAligned = getColAlignmentState(
      menuRectBlocks,
      ColAlignmentDirection.top,
    );
    if (isTopAligned) return ColAlignmentDirection.top;

    return ColAlignmentDirection.middle;
  }

  static bool getColAlignmentState(
    MenuRectBlockList menuRectBlocks,
    ColAlignmentDirection colAlign,
  ) {
    final testRowCoordList = _getColTestCoordList(menuRectBlocks, colAlign);
    final slopeList = _getSlopeList(
      testRowCoordList,
      (coord, nextCoord) => _getSlope(
        x1: coord.x.toDouble(),
        y1: coord.y.toDouble(),
        x2: nextCoord.x.toDouble(),
        y2: nextCoord.y.toDouble(),
      ),
    )
        .map(
          (e) => e.toInt(),
        )
        .toList();

    return _getAlignedStateByCoordList(slopeList);
  }

  static List<Coord> _getRowTestCoordList(
    MenuRectBlockList menuRectBlocks,
    RowAlignmentDirection align,
  ) {
    late List<Coord> testCoordList;
    switch (align) {
      case RowAlignmentDirection.left:
        testCoordList =
            menuRectBlocks.map((block) => block.textRectBlock.tl).toList();
        break;
      case RowAlignmentDirection.center:
        testCoordList =
            menuRectBlocks.map((block) => block.textRectBlock.center).toList();
        break;
      case RowAlignmentDirection.right:
        testCoordList =
            menuRectBlocks.map((block) => block.textRectBlock.tr).toList();
        break;
      default:
        throw Exception("choose light col align option");
    }
    return testCoordList;
  }

  static List<Coord> _getColTestCoordList(
    MenuRectBlockList menuRectBlocks,
    ColAlignmentDirection align,
  ) {
    late List<Coord> testCoordList;
    switch (align) {
      case ColAlignmentDirection.top:
        testCoordList =
            menuRectBlocks.map((block) => block.textRectBlock.tl).toList();
        break;
      case ColAlignmentDirection.middle:
        testCoordList =
            menuRectBlocks.map((block) => block.textRectBlock.center).toList();
        break;
      case ColAlignmentDirection.bottom:
        testCoordList =
            menuRectBlocks.map((block) => block.textRectBlock.bl).toList();
        break;
      default:
        throw Exception("choose light row align option");
    }
    return testCoordList;
  }
}
