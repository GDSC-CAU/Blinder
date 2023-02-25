import 'package:app/core/menu_parser.dart';
import 'package:app/core/menu_rect_block.dart';
import 'package:app/core/statics.dart';
import 'package:app/core/text_rect_block.dart';
import 'package:app/models/food_menu.dart';
import 'package:app/utils/array.dart';
import 'package:app/utils/sort.dart';
import 'package:app/utils/text.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class MenuEngine {
  final CategoryFilterFunction categoryFilterFunction;
  final TextRecognizer _textRecognizer;
  final MenuParser _parser;

  MenuRectBlockList menuRectBlockList = [];

  MenuRectBlockList get category => _parser.getCategory();
  List<FoodMenu> get foodMenu => _parser.getAllFoodMenu();

  MenuEngine({
    required this.categoryFilterFunction,
  })  : _textRecognizer = GoogleMlKit.vision.textRecognizer(
          script: TextRecognitionScript.korean,
        ),
        _parser = MenuParser(
          categoryFilterFunction: categoryFilterFunction,
        );

  Future<void> _initializeParserFromImage(
    InputImage image,
  ) async {
    final recognizedText = await _textRecognizer.processImage(image);
    _textRecognizer.close();

    menuRectBlockList = _getMenuRectBlockListByRecognizedText(
      recognizedText,
    );
    _setupBlockList();
    _parser.menuRectBlockList = menuRectBlockList;
  }

  /// parse food menu
  Future<void> parse(
    InputImage image,
  ) async {
    if (menuRectBlockList.isNotEmpty) {
      menuRectBlockList = [];
    }
    await _initializeParserFromImage(image);
  }

  MenuRectBlockList _getMenuRectBlockListByRecognizedText(
    RecognizedText recognizedText,
  ) {
    final MenuRectBlockList menuRectBlocks = [];

    for (final TextBlock block in recognizedText.blocks) {
      for (final TextLine line in block.lines) {
        for (final TextElement element in line.elements) {
          menuRectBlocks.add(
            MenuRectBlock(
              text: element.text,
              textRectBlock: TextRectBlock(
                initialPosition: RectPosition(
                  tl: Coord(
                    x: element.cornerPoints[0].x,
                    y: element.cornerPoints[0].y,
                  ),
                  tr: Coord(
                    x: element.cornerPoints[1].x,
                    y: element.cornerPoints[1].y,
                  ),
                  br: Coord(
                    x: element.cornerPoints[2].x,
                    y: element.cornerPoints[2].y,
                  ),
                  bl: Coord(
                    x: element.cornerPoints[3].x,
                    y: element.cornerPoints[3].y,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return menuRectBlocks;
  }

  void _setupBlockList() {
    _sortBlockListByCoordYX();
    _normalizeBlockList();
    _filterBlockByHeightDistribution();
    _sortBlockListByCoordYX();
    _combineBlockListBySearchRange();
  }

  // ignore: use_setters_to_change_properties
  void _updateMenuRectBlockList(MenuRectBlockList updatedList) {
    menuRectBlockList = updatedList;
  }

  /// sort coord by `y` -> `x`
  void _sortBlockListByCoordYX() {
    menuRectBlockList.sort(
      (blockA, blockB) => ascendingSort(
        blockA.textRectBlock.center.y,
        blockB.textRectBlock.center.y,
      ),
    );

    final sortedMenuBlockList = menuRectBlockList.fold<MenuRectBlockList>(
      [],
      (sorted, block) {
        if (sorted.isEmpty ||
            block.textRectBlock.center.y >=
                sorted.last.textRectBlock.center.y) {
          sorted.add(block);
          return sorted;
        }

        final tempCenterCoord = sorted.last.textRectBlock.center;
        final centerCoord = block.textRectBlock.center;

        final centerCoordSortedByX = Coord(
          x: tempCenterCoord.x > centerCoord.x
              ? centerCoord.x
              : tempCenterCoord.x,
          y: centerCoord.y,
        );

        final width = block.textRectBlock.width;
        final height = block.textRectBlock.height;

        sorted.last = MenuRectBlock(
          text: block.text,
          textRectBlock: TextRectBlock(
            initialPosition: RectPosition.fromBox(
              centerCoordSortedByX,
              width: width,
              height: height,
            ),
          ),
        );
        return sorted;
      },
    );

    _updateMenuRectBlockList(sortedMenuBlockList);
  }

  List<int> _normalize(List<int> dataList, int interval) {
    final double avg = Statics.avg(dataList);
    final int tolerance = interval ~/ 2;

    final List<int> normalizedData = dataList.map(
      (data) {
        final normalizedValue =
            ((data - avg) ~/ interval) * interval + avg.toInt();
        final diff = (data - normalizedValue).abs();

        return (diff <= tolerance)
            ? normalizedValue
            : (normalizedValue + interval);
      },
    ).toList();

    return normalizedData;
  }

  /// normalize block coord and height
  /// ```dart
  /// final unNormalized = [1,2,2,1,3,2,1, 11,10,12,10,12,13, 21,22,23,21,22,21];
  /// final normalized = [2,2,2,2,2,2,2, 11,11,11,11,11,11, 22,22,22,22,22,22,22];
  /// ```
  void _normalizeBlockList() {
    final yCoordList =
        menuRectBlockList.map((e) => e.textRectBlock.tl.y).toList();
    final heightList =
        menuRectBlockList.map((e) => e.textRectBlock.height).toList();

    final heightStd = Statics.std(heightList).toInt();
    final yCoordDiffList = heightList.fold<List<int>>([], (acc, curr) {
      if (acc.isEmpty) acc.add(curr);
      acc.add((curr - acc.last).abs());
      return acc;
    });
    final yCoordDiffStd = Statics.std(yCoordDiffList).toInt();

    final normalizedYCoordList = _normalize(yCoordList, yCoordDiffStd);
    final normalizedHeight = _normalize(heightList, heightStd);

    final normalizedMenuRectBlockList =
        normalizedYCoordList.folder<MenuRectBlockList>(
      [],
      (normalizedList, normalizedY, i, _) {
        final currentMenuBlock = menuRectBlockList[i];
        final currentRectHeight = normalizedHeight[i];

        final currentLeftX = currentMenuBlock.textRectBlock.tl.x;
        final currentRightX = currentMenuBlock.textRectBlock.tr.x;

        final updatedMenuBlock = MenuRectBlock(
          text: currentMenuBlock.text,
          textRectBlock: TextRectBlock(
            initialPosition: RectPosition(
              tl: Coord(x: currentLeftX, y: normalizedY),
              bl: Coord(x: currentLeftX, y: normalizedY + currentRectHeight),
              tr: Coord(x: currentRightX, y: normalizedY),
              br: Coord(x: currentRightX, y: normalizedY + currentRectHeight),
            ),
          ),
        );

        normalizedList.add(updatedMenuBlock);
        return normalizedList;
      },
    );

    _updateMenuRectBlockList(normalizedMenuRectBlockList);
  }

  void _combineBlockListBySearchRange({
    int searchRange = 3,
  }) {
    MenuRectBlock _getCombinedBlockByRange({
      required MenuRectBlockList list,
      required int listHeightAvg,
      required int beforeRange,
      required int afterRange,
      required int currIndex,
    }) {
      final self = list[currIndex];

      final beforeRangeList =
          list.getRange(currIndex - beforeRange, currIndex).toList();
      final afterRangeList =
          list.getRange(currIndex + 1, afterRange + (currIndex + 1)).toList();
      final testRange = [...beforeRangeList, ...afterRangeList];

      final combinedBlock = testRange.folder<MenuRectBlockList>(
        [self],
        (combined, currBlock, i, tot) {
          if (MenuRectBlock.getCombinableState(
            combined.last,
            currBlock,
            toleranceX: listHeightAvg,
            toleranceY: listHeightAvg ~/ 2,
          )) {
            final combinedBlock = MenuRectBlock.combine(
              combined.last,
              currBlock,
            );
            combined.add(combinedBlock);
            return combined;
          }

          return combined;
        },
      ).last;

      return combinedBlock;
    }

    bool _isNameDuplicated(
      String newTarget,
      String origin,
    ) =>
        newTarget.contains(origin);

    bool _isSelfDuplicated(
      MenuRectBlock blockSelf,
      MenuRectBlockList blockList,
    ) {
      final textList = blockList.map((e) => e.text);
      final shouldRemoveSelf = textList.fold<List<bool>>(
        [],
        (acc, curr) {
          acc.add(_isNameDuplicated(curr, blockSelf.text));
          return acc;
        },
      ).any((element) => element == true);

      return shouldRemoveSelf;
    }

    MenuRectBlockList _getDeduplicatedBlock({
      required MenuRectBlock targetBlock,
      required MenuRectBlockList totBlock,
    }) {
      final List<int> duplicatedIndexList = totBlock.folder(
        [],
        (acc, curr, i, _) {
          if (_isNameDuplicated(targetBlock.text, curr.text)) {
            acc.add(i);
            return acc;
          }
          return acc;
        },
      );

      return totBlock.filter(
        (current, i) => duplicatedIndexList.contains(i) == false,
      );
    }

    Map<String, int> _getRangeByCurrentIndex({
      required int currentIndex,
      required int givenRange,
      required int totLength,
    }) {
      if (currentIndex - searchRange < 0) {
        return {
          "before": currentIndex,
          "after": givenRange,
        };
      }
      if (searchRange + (currentIndex + 1) > totLength) {
        return {
          "before": givenRange,
          "after": totLength - (currentIndex + 1),
        };
      }
      return {
        "before": givenRange,
        "after": givenRange,
      };
    }

    final combinedBlockList = menuRectBlockList.folder<MenuRectBlockList>(
      [],
      (combinedList, currBlock, i, _) {
        if (i == 0) {
          combinedList.add(currBlock);
          return combinedList;
        }

        if (isPriceText(currBlock.text)) {
          combinedList.add(currBlock);
          return combinedList;
        }
        final calculatedRange = _getRangeByCurrentIndex(
          currentIndex: i,
          givenRange: searchRange,
          totLength: menuRectBlockList.length,
        );

        final combinedBlock = _getCombinedBlockByRange(
          currIndex: i,
          list: menuRectBlockList,
          listHeightAvg: Statics.avg(
            menuRectBlockList
                .map(
                  (e) => e.textRectBlock.height,
                )
                .toList(),
          ).toInt(),
          beforeRange: calculatedRange["before"]!,
          afterRange: calculatedRange["after"]!,
        );

        combinedList = _getDeduplicatedBlock(
          targetBlock: combinedBlock,
          totBlock: combinedList,
        );

        if (_isSelfDuplicated(combinedBlock, combinedList)) {
          return combinedList;
        }

        combinedList.add(combinedBlock);
        return combinedList;
      },
    );

    _updateMenuRectBlockList(combinedBlockList);
  }

  /// Filter tiny & huge text by rect height
  void _filterBlockByHeightDistribution() {
    final heightList =
        menuRectBlockList.map((e) => e.textRectBlock.height).toList();

    bool _getFilterStateByStepPoints(
      int currentIndex, {
      required int? first,
      required int? last,
    }) {
      if (first == null) return false;
      if (last == null) return currentIndex <= first;
      return currentIndex <= first || currentIndex > last;
    }

    final stepPoints = Statics.getSideStepPoint(heightList);
    final filteredMenuBlockList = menuRectBlockList.folder<MenuRectBlockList>(
      [],
      (filtered, block, currentIndex, _) {
        if (_getFilterStateByStepPoints(
          currentIndex,
          first: stepPoints["first"],
          last: stepPoints["last"],
        )) return filtered;

        filtered.add(block);
        return filtered;
      },
    );

    _updateMenuRectBlockList(filteredMenuBlockList);
  }
}
