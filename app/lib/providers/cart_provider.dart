import 'package:app/common/styles/colors.dart';
import 'package:app/models/food_cart_item.dart';
import 'package:flutter/material.dart';

class FoodCartProvider with ChangeNotifier {
  final List<FoodCartItem> foodCartItems = [];

  void addFoodCartItem(FoodCartItem newFoodCartItem) {
    foodCartItems.add(newFoodCartItem);
    _printFoodCartItems();
    notifyListeners();
  }

  void clearFoodCartItems() {
    foodCartItems.clear();
  }

  num getTotalPrice() => foodCartItems.fold(
        0,
        (previousValue, element) =>
            previousValue + element.price * element.count,
      );

  void _printFoodCartItems() {
    print('Print Cart Items');
    foodCartItems.map((e) => e.toString()).forEach(print);
    print('');
  }

  List<DataRow> getFoodCartItemList() => foodCartItems
      .map(
        (item) => DataRow(
          cells: [
            DataCell(
              Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(
              Text(
                "${item.count}개",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(
              Text(
                "${item.price}원",
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  decorationColor: Palette.$brown700,
                  decorationStyle: TextDecorationStyle.wavy,
                ),
              ),
            ),
          ],
        ),
      )
      .toList();

  @override
  String toString() => foodCartItems
      .map(
        (item) => item.toString(),
      )
      .fold(
        "",
        (prev, itemString) => "$prev$itemString",
      );
}
