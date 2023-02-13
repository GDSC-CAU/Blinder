import 'package:app/models/food_cart_item.dart';
import 'package:flutter/material.dart';

class FoodCartProvider with ChangeNotifier {
  final List<FoodCartItem> foodCartItems = [];

  void addItem(FoodCartItem newFoodCartItem) {
    foodCartItems.add(newFoodCartItem);
    _printItems();
    notifyListeners();
  }

  void clearItems() {
    foodCartItems.clear();
  }

  num getTotalPrice() =>
      foodCartItems.map((item) => item.price).reduce((prev, cur) => prev + cur);

  void _printItems() {
    print('Print Cart Items');
    foodCartItems.map((e) => e.toString()).forEach(print);
    print('');
  }

  List<DataRow> getFoodCartItemList() => foodCartItems
      .map(
        (item) => DataRow(
          cells: [
            DataCell(Text(item.name)),
            DataCell(Text("${item.count}")),
            DataCell(Text("${item.price}")),
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
