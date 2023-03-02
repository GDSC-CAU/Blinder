// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:app/core/block/block.dart';
import 'package:app/core/block/menu_block.dart';
import 'package:app/core/clusters/clustering_engine.dart';
import 'package:app/core/utils/sort.dart';
import 'package:app/core/utils/statics.dart';
import 'package:app/models/food_menu.dart';
import 'package:app/models/model_factory.dart';
import 'package:app/utils/array.dart';
import 'package:app/utils/text.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

typedef MenuBlockList = List<MenuBlock>;

class MenuEngine {
  final TextRecognizer _textRecognizer;
  late final ClusteringEngine clusteringEngine;

  MenuBlockList menuBlockList = [];

  List<FoodMenu> get foodMenu => getAllFoodMenu();

  MenuEngine()
      : _textRecognizer = GoogleMlKit.vision.textRecognizer(
          script: TextRecognitionScript.korean,
        );

  Future<void> _initializeParser(
    InputImage image,
  ) async {
    final recognizedText = await _textRecognizer.processImage(image);
    _textRecognizer.close();

    menuBlockList = _getMenuRectBlockListByRecognizedText(
      recognizedText,
    );
    _setupBlockList();
    _initializeClusteringEngine();
  }

  /// Parse food menu
  Future<void> parse(
    InputImage image,
  ) async {
    if (menuBlockList.isNotEmpty) {
      menuBlockList = [];
    }
    await _initializeParser(image);
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
    _combineBlockList();
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

  void _combineBlockList({
    double scaleRatioOfSearchWidth = 2,
    double scaleRatioOfSearchHeight = 0.75,
  }) {
    final heightAvg = Statics.avg(
      menuBlockList.map((e) => e.block.height).toList(),
    );
    final toleranceX = (heightAvg * scaleRatioOfSearchWidth).toInt();
    final toleranceY = (heightAvg * scaleRatioOfSearchHeight).toInt();

    MenuBlockList combineBlockListUntilEnd(
      MenuBlockList combineTargetBlockList,
    ) {
      final Set<int> _mergedIndex = {};

      final mergedBlockList = combineTargetBlockList.folder<MenuBlockList>(
        [],
        (mergedBlocks, currentMenuBlock, currentI, tot) {
          if (_mergedIndex.contains(currentI)) {
            return mergedBlocks;
          }

          final combinedMenuBlock = tot.folder<MenuBlockList>(
            [currentMenuBlock],
            (combinedMenuBlock, iterBlock, iterI, _) {
              if (currentI == iterI) {
                return combinedMenuBlock;
              }
              if (_mergedIndex.contains(iterI)) {
                return combinedMenuBlock;
              }

              if (MenuBlock.getCombinableState(
                combinedMenuBlock.last,
                iterBlock,
                toleranceX: toleranceX,
                toleranceY: toleranceY,
              )) {
                final combinedBlock = MenuBlock.combine(
                  combinedMenuBlock.last,
                  iterBlock,
                );
                combinedMenuBlock.add(combinedBlock);

                _mergedIndex.add(iterI);

                return combinedMenuBlock;
              }

              return combinedMenuBlock;
            },
          ).last;

          mergedBlocks.add(combinedMenuBlock);
          return mergedBlocks;
        },
      );

      final checkedIndex = <int>{};

      final isCombineNotCompleted = mergedBlockList
          .mapper<bool>(
            (currBlock, currI, _) => mergedBlockList.mapper<bool>(
              (iterBlock, iterI, _) {
                if (iterI == currI) return false;
                if (checkedIndex.contains(iterI)) return false;

                final isCombinePossible = MenuBlock.getCombinableState(
                  currBlock,
                  iterBlock,
                  toleranceX: toleranceX,
                  toleranceY: toleranceY,
                );
                checkedIndex.add(iterI);
                return isCombinePossible;
              },
            ).any((isCombinePossible) => isCombinePossible),
          )
          .any((shouldCombineMore) => shouldCombineMore);

      if (isCombineNotCompleted) {
        return combineBlockListUntilEnd(mergedBlockList);
      } else {
        return mergedBlockList;
      }
    }

    final combinedBlockList = combineBlockListUntilEnd(menuBlockList);
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

  String _removeNonKoreanEnglishPriceNumber(String text) {
    const divider = "";
    final RegExp nonKoreanEnglishPriceNumber =
        RegExp(r'[^\uAC00-\uD7A3ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z0-9,.&]');
    return text
        .replaceAll(
          nonKoreanEnglishPriceNumber,
          divider,
        )
        .trim();
  }

  String _removeLastComma(String text) =>
      text.endsWith(",") ? text.replaceAll(RegExp(','), "") : text;

  void _removeInvalidCharacters() {
    final removedNonKoreanEnglishNumber = menuBlockList
        .map(
          (e) => MenuBlock(
            text: _removeLastComma(
              _removeNonKoreanEnglishPriceNumber(e.text),
            ),
            block: e.block,
          ),
        )
        .toList();

    _updateMenuBlockList(removedNonKoreanEnglishNumber);
  }

  void _filterBlocksByKOREAN_JOSA_LIST() {
    const Set<String> KOREAN_JOSA_LIST = {
      "가",
      "과",
      "을",
      "를",
      "이",
      "야",
      "나",
      "에",
      "게",
      "께",
      "아",
      "로",
      "여",
      "와",
      "고",
      "의",
      "랑",
      "은",
      "는",
      "도",
      "만",
      "뿐",
      "다",
      "시",
      "어",
      "이다",
      "으로",
      "에서",
      "에게",
      "이여",
      "로써",
      "보다",
      "라고",
      "하고",
      "이랑",
      "대로",
      "수가",
      "부터",
      "마다",
      "까지",
      "조차",
      "말로",
      "이야",
      "이나",
      "나마",
      "니다",
      "시면",
      "든지",
      "던지",
      "세요",
      "해요",
      "아요",
    };

    const KOREAN_LIST_NUMBER = <String>{
      "하나",
      "둘",
      "셋",
    };

    const KOREAN_PERSONAL_PRONOUNS = <String>{
      "저희",
    };

    const KOREAN_FILTER = [
      ...KOREAN_JOSA_LIST,
      ...KOREAN_LIST_NUMBER,
      ...KOREAN_PERSONAL_PRONOUNS
    ];

    bool _isJOSAIncluded(String word) => KOREAN_FILTER
        .map((josa) => word.endsWith(josa))
        .any((isJosaIncluded) => isJosaIncluded == true);

    final filteredByJOSA = menuBlockList.filter(
      (block, i) {
        const indent = " ";
        final wordListByIndent = block.text
            .split(indent)
            .map((word) => _removeNonKoreanEnglishPriceNumber(word));

        final isWordCouldBeSentence = wordListByIndent
                .map((word) => _isJOSAIncluded(word))
                .toList()
                .filter((josa, _) => josa)
                .length >=
            2;

        if (isWordCouldBeSentence) {
          print("조사 필터링: ${block.text}");
          return false;
        }
        return true;
      },
    );

    _updateMenuBlockList(filteredByJOSA);
  }

  void _initializeClusteringEngine() {
    clusteringEngine = ClusteringEngine(
      menuBlockList: menuBlockList,
    );
  }

  MenuBlockList _filterSelf(MenuBlock targetBlock) => menuBlockList.filter(
        (block, i) =>
            block.block.tl != targetBlock.block.tl ||
            block.text != targetBlock.text,
      );

  MenuBlockList _searchAxisByY(
    MenuBlock targetBlock, {
    required int tolerance,
  }) {
    final MenuBlockList targetList = _filterSelf(
      targetBlock,
    ).fold<MenuBlockList>(
      [],
      (ySimilar, block) {
        if ((targetBlock.block.tl.y - block.block.tl.y).abs() <= tolerance) {
          ySimilar.add(block);
        }
        return ySimilar;
      },
    );
    targetList.sort(
      (a, b) => ascendingSort(a.block.tl.x, b.block.tl.x),
    );

    return targetList;
  }

  FoodMenu _generateFoodMenu(JsonMap jsonMap) {
    final foodMenu = ModelFactory(FoodMenu());
    foodMenu.serialize(jsonMap);

    return foodMenu.data!;
  }

  List<FoodMenu> getAllFoodMenu() {
    final menuList = menuBlockList.fold<List<FoodMenu>>(
      [],
      (
        filteredMenuList,
        menuBlock,
      ) {
        if (isPriceText(menuBlock.text)) return filteredMenuList;

        final searchedByCurrentY = _searchAxisByY(
          menuBlock,
          tolerance: (menuBlock.block.height).toInt(),
        );
        final rightSideOfCurrentX = searchedByCurrentY
            .where((element) => element.block.tl.x > menuBlock.block.tl.x)
            .toList();

        if (rightSideOfCurrentX.isEmpty) return filteredMenuList;

        final rightSide = rightSideOfCurrentX.first;
        if (isPriceText(rightSide.text) == false) return filteredMenuList;

        final foodMenu = _generateFoodMenu({
          "name": menuBlock.text,
          "price": rightSideOfCurrentX.first.text,
        });

        filteredMenuList.add(foodMenu);
        return filteredMenuList;
      },
    );
    return menuList;
  }
}
