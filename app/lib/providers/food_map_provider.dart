import 'package:app/models/food_map.dart';
import 'package:app/models/food_menu.dart';
import 'package:app/models/model_factory.dart';
import 'package:flutter/material.dart';

class FoodMapProvider extends ChangeNotifier {
  final foodMap = ModelFactory(FoodMap());

  List<String> getFoodCategory() =>
      foodMap.dataList.map((food) => food.category).toList();

  List<FoodMenu> getFoodMenuByCategory(String category) =>
      foodMap.dataList.firstWhere((food) => food.category == category).menu;

  void updateFoodMapFromJson(List<JsonMap> jsonList) {
    foodMap.serializeList(jsonList);
  }

  List<JsonMap> getDeserializedFoodMap() =>
      ModelFactory.deserializeList(foodMap.dataList);
}
