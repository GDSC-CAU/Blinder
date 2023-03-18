import 'package:app/models/food_menu.dart';
import 'package:app/models/model_factory.dart';
import 'package:flutter/material.dart';

class FoodMenuProvider extends ChangeNotifier {
  final foodMenuModel = ModelFactory(FoodMenu());

  final List<FoodMenu> foodMenuList = [];

  void updateFoodMenuFromJson(List<JsonMap> foodMenuJsonList) {
    foodMenuModel.serializeList(foodMenuJsonList);
    updateFoodMenu(foodMenuModel.dataList);
  }

  void updateFoodMenu(List<FoodMenu> newFoodMenuList) {
    if (foodMenuList.isNotEmpty) foodMenuList.clear();
    foodMenuList.addAll(newFoodMenuList);
  }

  List<JsonMap> getFoodMenuJson() =>
      ModelFactory.deserializeList(foodMenuModel.dataList);
}
