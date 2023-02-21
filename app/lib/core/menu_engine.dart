import 'package:app/core/menu_parser.dart';
import 'package:app/core/menu_rect_block.dart';
import 'package:app/core/statics.dart';
import 'package:app/core/text_rect_block.dart';
import 'package:app/models/food_menu.dart';
import 'package:app/utils/array_util.dart';
import 'package:app/utils/sort.dart';
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
    _sortBlockListByCoordXY();
    _normalizeBlockList();

    _combineBlockList();
    _combineBlockList();
  }

  // ignore: use_setters_to_change_properties
  void _updateMenuRectBlockList(MenuRectBlockList updatedList) {
    menuRectBlockList = updatedList;
  }

  /// sort coord by `x` and `y`
  void _sortBlockListByCoordXY() {
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

  void _combineBlockList() {
    final combinedBlockList = menuRectBlockList.folder<MenuRectBlockList>(
      [],
      (combined, block, i, tot) {
        final isBeginEndPoint = i == 0 || i == menuRectBlockList.length;
        if (isBeginEndPoint) {
          combined.add(block);
          return combined;
        }

        final isCombinable = MenuRectBlock.getCombinableState(
          combined.last,
          block,
        );
        if (isCombinable) {
          final combinedBlock = MenuRectBlock.combine(
            combined.last,
            block,
          );
          combined.removeLast();
          combined.add(combinedBlock);
          return combined;
        } else {
          combined.add(block);
          return combined;
        }
      },
    );

    _updateMenuRectBlockList(combinedBlockList);
  }
}
