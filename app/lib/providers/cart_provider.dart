import 'package:app/models/food_cart_item.dart';
import 'package:flutter/material.dart';

class FoodCartProvider with ChangeNotifier {
  final List<FoodCartItem> foodCartItems = [];

  void addItem(FoodCartItem newFoodCartItem) {
    foodCartItems.add(newFoodCartItem);
    notifyListeners();
  }

  void printItems() => foodCartItems.map((e) => e.toString()).forEach(print);

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
