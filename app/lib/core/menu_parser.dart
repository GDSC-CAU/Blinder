import 'package:app/core/block/menu_block.dart';
import 'package:app/core/utils/sort.dart';
import 'package:app/core/utils/statics.dart';
import 'package:app/models/food_menu.dart';
import 'package:app/models/model_factory.dart';
import 'package:app/utils/array.dart';
import 'package:app/utils/text.dart';

typedef MenuBlockList = List<MenuBlock>;
typedef CategoryFilterFunction = bool Function(String category);

class MenuParser {
  /// **Inject ML category `NL` model function**
  final CategoryFilterFunction categoryFilterFunction;
  MenuBlockList parserMenuBlockList = [];

  // ignore: use_setters_to_change_properties
  void updateParserMenuRectBlockList(MenuBlockList newMenuRectBlockList) {
    parserMenuBlockList = newMenuRectBlockList;
  }

  MenuParser({
    required this.categoryFilterFunction,
  });

  MenuBlockList _filterSelf(MenuBlock targetBlock) =>
      parserMenuBlockList.filter(
        (block, i) =>
            block.block.tl != targetBlock.block.tl ||
            block.text != targetBlock.text,
      );

  MenuBlockList _searchAxisByY(
    MenuBlock targetBlock, {
    required int tolerance,
  }) {
    final targetList = _filterSelf(targetBlock).fold<MenuBlockList>(
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

  ///TODO: alignment 조건 달기
  List<FoodMenu> getAllFoodMenu() {
    final menuList =
        parserMenuBlockList.fold<List<FoodMenu>>([], (filteredMenuList, block) {
      if (isPriceText(block.text)) return filteredMenuList;

      final searchedByCurrentY = _searchAxisByY(
        block,
        tolerance: block.block.height,
      );
      final rightSideOfCurrentX = searchedByCurrentY
          .where((element) => element.block.tl.x > block.block.tl.x)
          .toList();

      if (rightSideOfCurrentX.isEmpty) return filteredMenuList;

      final rightSide = rightSideOfCurrentX.first;
      if (isPriceText(rightSide.text) == false) return filteredMenuList;

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

  MenuBlockList getCategory() {
    final heightArray =
        parserMenuBlockList.map((block) => block.block.height).toList();
    heightArray.sort();
    final heightAvg = Statics.avg(heightArray);

    final categoryTextBlocksByHeight = parserMenuBlockList.fold<MenuBlockList>(
      [],
      (filtered, block) {
        if (block.block.height > heightAvg) {
          filtered.add(block);
          return filtered;
        }
        return filtered;
      },
    );

    ///TODO: 일단 제외 / align condition 추가
    final categoryTextBlocksByMoneyCondition =
        categoryTextBlocksByHeight.fold<MenuBlockList>([], (filtered, block) {
      if (isPriceText(block.text)) return filtered;

      final searchedByCurrentY = _searchAxisByY(
        block,
        tolerance: block.block.height ~/ 2,
      );
      final rightSideOfCurrentX = searchedByCurrentY
          .where((element) => element.block.tl.x > block.block.tl.x)
          .toList();

      if (rightSideOfCurrentX.isEmpty) {
        filtered.add(block);
        return filtered;
      }

      if (rightSideOfCurrentX.any((block) => isPriceText(block.text))) {
        final heightList =
            rightSideOfCurrentX.map((e) => e.block.height).toList();

        if (block.block.height >
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
        categoryTextBlocksByMoneyCondition.fold<MenuBlockList>(
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
