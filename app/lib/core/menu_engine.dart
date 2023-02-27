// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:app/core/block/block.dart';
import 'package:app/core/block/menu_block.dart';
import 'package:app/core/menu_parser.dart';
import 'package:app/core/utils/sort.dart';
import 'package:app/core/utils/statics.dart';
import 'package:app/models/food_menu.dart';
import 'package:app/utils/array.dart';
import 'package:app/utils/text.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class MenuEngine {
  final CategoryFilterFunction categoryFilterFunction;
  final TextRecognizer _textRecognizer;
  final MenuParser _parser;

  MenuBlockList menuBlockList = [];

  MenuBlockList get category => _parser.getCategory();
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

    menuBlockList = _getMenuRectBlockListByRecognizedText(
      recognizedText,
    );
    _setupBlockList();
    _parser.updateParserMenuRectBlockList(menuBlockList);
  }

  /// Parse food menu
  Future<void> parse(
    InputImage image,
  ) async {
    if (menuBlockList.isNotEmpty) {
      menuBlockList = [];
    }
    await _initializeParserFromImage(image);
  }

  MenuBlockList _getMenuRectBlockListByRecognizedText(
    RecognizedText recognizedText,
  ) {
    final MenuBlockList transformedMenuBlockList = [];

    for (final TextBlock block in recognizedText.blocks) {
      for (final TextLine line in block.lines) {
        for (final TextElement element in line.elements) {
          transformedMenuBlockList.add(
            MenuBlock(
              text: element.text,
              block: Block(
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

    return transformedMenuBlockList;
  }

  void _setupBlockList() {
    _sortBlockListByCoordYX();
    _normalizeBlockList();
    _filterBlockByHeightDistribution();
    _sortBlockListByCoordYX();
    _combineBlockListBySearchRange(
      toleranceXRatio: 2,
    );
    _filterBlocksByKOREAN_JOSA_LIST();
    _removeInvalidCharacters();
  }

  // ignore: use_setters_to_change_properties
  void _updateMenuBlockList(MenuBlockList updatedMenuBlockList) {
    menuBlockList = updatedMenuBlockList;
  }

  /// sort coord by `y` -> `x`
  void _sortBlockListByCoordYX() {
    menuBlockList.sort(
      (blockA, blockB) => ascendingSort(
        blockA.block.center.y,
        blockB.block.center.y,
      ),
    );

    final sortedMenuBlockList = menuBlockList.fold<MenuBlockList>(
      [],
      (sorted, block) {
        if (sorted.isEmpty ||
            block.block.center.y >= sorted.last.block.center.y) {
          sorted.add(block);
          return sorted;
        }

        final tempCenterCoord = sorted.last.block.center;
        final centerCoord = block.block.center;

        final centerCoordSortedByX = Coord(
          x: tempCenterCoord.x > centerCoord.x
              ? centerCoord.x
              : tempCenterCoord.x,
          y: centerCoord.y,
        );

        final width = block.block.width;
        final height = block.block.height;

        sorted.last = MenuBlock(
          text: block.text,
          block: Block(
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

    _updateMenuBlockList(sortedMenuBlockList);
  }

  void _normalizeBlockList() {
    final yCoordList = menuBlockList.map((e) => e.block.tl.y).toList();
    final heightList = menuBlockList.map((e) => e.block.height).toList();

    final heightStd = Statics.std(heightList).toInt();
    final yCoordDiffList = heightList.fold<List<int>>([], (acc, curr) {
      if (acc.isEmpty) acc.add(curr);
      acc.add((curr - acc.last).abs());
      return acc;
    });
    final yCoordDiffStd = Statics.std(yCoordDiffList).toInt();

    final normalizedYCoordList = Statics.normalize(
      intList: yCoordList,
      interval: yCoordDiffStd,
    );
    final normalizedHeight = Statics.normalize(
      intList: heightList,
      interval: heightStd,
    );

    final normalizedMenuRectBlockList =
        normalizedYCoordList.folder<MenuBlockList>(
      [],
      (normalizedList, normalizedY, i, _) {
        final currentMenuBlock = menuBlockList[i];
        final currentRectHeight = normalizedHeight[i];

        final currentLeftX = currentMenuBlock.block.tl.x;
        final currentRightX = currentMenuBlock.block.tr.x;

        final updatedMenuBlock = MenuBlock(
          text: currentMenuBlock.text,
          block: Block(
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

    _updateMenuBlockList(normalizedMenuRectBlockList);
  }

  void _combineBlockListBySearchRange({
    int searchRange = 3,
    double toleranceXRatio = 1.5,
    double toleranceYRatio = 0.5,
  }) {
    MenuBlock _getCombinedBlockByRange({
      required MenuBlockList list,
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

      final combinedBlock = testRange.folder<MenuBlockList>(
        [self],
        (combined, currBlock, i, tot) {
          if (MenuBlock.getCombinableState(
            combined.last,
            currBlock,
            toleranceX: (listHeightAvg * toleranceXRatio).toInt(),
            toleranceY: (listHeightAvg * toleranceYRatio).toInt(),
          )) {
            final combinedBlock = MenuBlock.combine(
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
      MenuBlock blockSelf,
      MenuBlockList blockList,
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

    MenuBlockList _getDeduplicatedBlock({
      required MenuBlock targetBlock,
      required MenuBlockList totBlock,
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

    final combinedBlockList = menuBlockList.folder<MenuBlockList>(
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
          totLength: menuBlockList.length,
        );

        final combinedBlock = _getCombinedBlockByRange(
          currIndex: i,
          list: menuBlockList,
          listHeightAvg: Statics.avg(
            menuBlockList
                .map(
                  (e) => e.block.height,
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

    _updateMenuBlockList(combinedBlockList);
  }

  /// Filter tiny & huge text by rect height
  void _filterBlockByHeightDistribution() {
    final heightList = menuBlockList.map((e) => e.block.height).toList();

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
    final filteredMenuBlockList = menuBlockList.folder<MenuBlockList>(
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

    _updateMenuBlockList(filteredMenuBlockList);
  }

  void _removeInvalidCharacters() {
    String removeNonKoreanEnglishPriceNumber(String input) {
      final RegExp nonKoreanEnglishPriceNumber =
          RegExp(r'[^\uAC00-\uD7A3ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z0-9,.]');
      return input.replaceAll(nonKoreanEnglishPriceNumber, '').trim();
    }

    final removedNonKoreanEnglishNumber = menuBlockList
        .map(
          (e) => MenuBlock(
            text: removeNonKoreanEnglishPriceNumber(e.text),
            block: e.block,
          ),
        )
        .toList();

    _updateMenuBlockList(removedNonKoreanEnglishNumber);
  }

  void _filterBlocksByKOREAN_JOSA_LIST() {
    const Set<String> KOREAN_JOSA_LIST = {
      "를",
      "여",
      "의",
      "는",
      "은",
      "뿐",
      "에",
      "이",
      "께",
      "만",
      "보다",
      "하고",
      "부터",
      "이야",
      "이나",
      "나마",
      "시면",
      "으로",
      "에서",
      "에게",
      "이여",
      "로써",
      "라고",
      "이랑",
      "대로",
      "수가",
      "마다",
      "까지",
      "조차",
      "말로",
      "든지",
      "던지",
    };

    bool _isJOSAIncluded(String word) => KOREAN_JOSA_LIST
        .map((josa) => word.endsWith(josa))
        .any((isJosaIncluded) => isJosaIncluded == true);

    final filteredByJOSA = menuBlockList.filter(
      (block, i) {
        final wordList = block.text.split(" ");

        final isJOSAIncluded = wordList
            .map(
              (word) => _isJOSAIncluded(word),
            )
            .any(
              (isJOSAIncluded) => isJOSAIncluded == true,
            );

        return isJOSAIncluded == false;
      },
    );

    _updateMenuBlockList(filteredByJOSA);
  }
}
