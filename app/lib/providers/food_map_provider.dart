import 'package:app/models/food_map.dart';
import 'package:app/models/food_menu.dart';
import 'package:flutter/material.dart';

class FoodMapProvider extends ChangeNotifier {
  final List<FoodMap> foodMap = [];

  FoodMapProvider();

  List<String> getFoodCategory() =>
      foodMap.map((food) => food.category).toList();

  List<FoodMenu> getFoodMenuByCategory(String category) =>
      foodMap.firstWhere((food) => food.category == category).menu;

  void updateFoodMap(List<FoodMap> newFoodMap) {
    foodMap.clear();
    foodMap.addAll(newFoodMap);

    notifyListeners();
  }
}
