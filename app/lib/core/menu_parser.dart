import 'package:app/core/menu_rect_block.dart';
import 'package:app/core/statics.dart';
import 'package:app/models/food_menu.dart';
import 'package:app/models/model_factory.dart';
import 'package:app/utils/array_util.dart';
import 'package:app/utils/sort.dart';

typedef MenuRectBlockList = List<MenuRectBlock>;
typedef CategoryFilterFunction = bool Function(String category);

class MenuParser {
  /// **Inject ML category `NL` model function**
  final CategoryFilterFunction categoryFilterFunction;
  MenuRectBlockList menuRectBlockList = [];

  MenuParser({
    required this.categoryFilterFunction,
  });

  MenuRectBlockList _filterSelf(MenuRectBlock targetBlock) =>
      menuRectBlockList.filter(
        (block, i) =>
            block.textRectBlock.tl != targetBlock.textRectBlock.tl ||
            block.text != targetBlock.text,
      );

  MenuRectBlockList _searchAxisByY(
    MenuRectBlock targetBlock, {
    required int tolerance,
  }) {
    final targetList = _filterSelf(targetBlock).fold<MenuRectBlockList>(
      [],
      (ySimilar, block) {
        if ((targetBlock.textRectBlock.tl.y - block.textRectBlock.tl.y).abs() <=
            tolerance) {
          ySimilar.add(block);
        }
        return ySimilar;
      },
    );
    targetList.sort(
      (a, b) => ascendingSort(a.textRectBlock.tl.x, b.textRectBlock.tl.x),
    );

    return targetList;
  }

  bool _isPriceText(String text) {
    const price = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
    const priceTextBoundaryCount = 2;
    final isPriceText = text.split("").fold<List<bool>>(
          [],
          (priceTextTester, currText) {
            priceTextTester.add(price.contains(currText));
            return priceTextTester;
          },
        ).fold(
          0,
          (numberOfPriceText, currentState) =>
              currentState ? numberOfPriceText + 1 : numberOfPriceText,
        ) >=
        priceTextBoundaryCount;

    return isPriceText;
  }

  FoodMenu _generateFoodMenu(JsonMap jsonMap) {
    final foodMenu = ModelFactory(FoodMenu());
    foodMenu.serialize(jsonMap);

    return foodMenu.data!;
  }

  ///TODO: alignment 조건 달기
  List<FoodMenu> getAllFoodMenu() {
    final menuList =
        menuRectBlockList.fold<List<FoodMenu>>([], (filteredMenuList, block) {
      if (_isPriceText(block.text)) return filteredMenuList;

      final searchedByCurrentY = _searchAxisByY(
        block,
        tolerance: block.textRectBlock.height,
      );
      final rightSideOfCurrentX = searchedByCurrentY
          .where((element) =>
              element.textRectBlock.tl.x > block.textRectBlock.tl.x)
          .toList();

      if (rightSideOfCurrentX.isEmpty) return filteredMenuList;

      final rightSide = rightSideOfCurrentX.first;
      if (_isPriceText(rightSide.text) == false) return filteredMenuList;

      final foodMenu = _generateFoodMenu({
        "name": block.text,
        "price": rightSideOfCurrentX.first.text.replaceAll(RegExp(','), ''),
      });

      filteredMenuList.add(foodMenu);
      return filteredMenuList;
    });

    final filteredMenuListByML = menuList.fold<List<FoodMenu>>(
      [],
      (filteredByML, categoryBlock) {
        if (categoryFilterFunction(categoryBlock.name)) {
          filteredByML.add(categoryBlock);
          return filteredByML;
        }
        return filteredByML;
      },
    );

    return filteredMenuListByML;
  }

  MenuRectBlockList getCategory() {
    final heightArray =
        menuRectBlockList.map((block) => block.textRectBlock.height).toList();
    heightArray.sort();
    final heightAvg = Statics.avg(heightArray);

    final categoryTextBlocksByHeight =
        menuRectBlockList.fold<MenuRectBlockList>(
      [],
      (filtered, block) {
        if (block.textRectBlock.height > heightAvg) {
          filtered.add(block);
          return filtered;
        }
        return filtered;
      },
    );

    ///TODO: 일단 제외 / align condition 추가
    final categoryTextBlocksByMoneyCondition = categoryTextBlocksByHeight
        .fold<MenuRectBlockList>([], (filtered, block) {
      if (_isPriceText(block.text)) return filtered;

      final searchedByCurrentY = _searchAxisByY(
        block,
        tolerance: block.textRectBlock.height ~/ 2,
      );
      final rightSideOfCurrentX = searchedByCurrentY
          .where((element) =>
              element.textRectBlock.tl.x > block.textRectBlock.tl.x)
          .toList();

      if (rightSideOfCurrentX.isEmpty) {
        filtered.add(block);
        return filtered;
      }

      if (rightSideOfCurrentX.any((block) => _isPriceText(block.text))) {
        final heightList =
            rightSideOfCurrentX.map((e) => e.textRectBlock.height).toList();

        if (block.textRectBlock.height >
            Statics.avg(heightList) + Statics.std(heightList)) {
          filtered.add(block);
          return filtered;
        }

        return filtered;
      }

      filtered.add(block);
      return filtered;
    });

    final filteredCategoryTextBlocksByML =
        categoryTextBlocksByMoneyCondition.fold<MenuRectBlockList>(
      [],
      (filteredByML, categoryBlock) {
        if (categoryFilterFunction(categoryBlock.text)) {
          filteredByML.add(categoryBlock);
          return filteredByML;
        }
        return filteredByML;
      },
    );

    return filteredCategoryTextBlocksByML;
  }
}
