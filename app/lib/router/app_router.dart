import 'package:app/screens/food_camera_screen.dart';
import 'package:app/screens/food_category_screen.dart';
import 'package:app/screens/food_counting_screen.dart';
import 'package:app/screens/food_menu_screen.dart';
import 'package:app/screens/food_receipt_screen.dart';
import 'package:app/screens/main_voice_screen.dart';
import 'package:flutter/material.dart';

enum RouterPath {
  mainVoice,
  foodCamera,
  foodCategory,
  foodMenu,
  foodCounting,
  foodReceipt,
}

class AppRouter {
  const AppRouter();

  static const String mainVoicePath = "/";
  static const String foodCameraPath = "/camera";
  static const String foodCategoryPath = "/food-category";
  static const String foodCountingPath = "/food-counting";
  static const String foodMenuPath = "/food-menu";
  static const String foodReceiptPath = "/food-receipt";

  static const Map<RouterPath, String> routePath = {
    RouterPath.mainVoice: mainVoicePath,
    RouterPath.foodCamera: foodCameraPath,
    RouterPath.foodCategory: foodCategoryPath,
    RouterPath.foodCounting: foodCountingPath,
    RouterPath.foodMenu: foodMenuPath,
    RouterPath.foodReceipt: foodReceiptPath,
  };

  static String initialRoute = RouterPath.mainVoice.name;
  static const Widget initialScreen = MainVoiceScreen();

  static final Map<String, Widget Function(BuildContext)> routes = {
    routePath[RouterPath.foodCamera] ?? foodCameraPath: (context) =>
        const FoodCameraScreen(),
    routePath[RouterPath.foodCategory] ?? foodCategoryPath: (context) =>
        const FoodCategoryScreen(),
    routePath[RouterPath.foodMenu] ?? foodMenuPath: (context) =>
        const FoodMenuScreen(),
    routePath[RouterPath.foodCounting] ?? foodCountingPath: (context) =>
        const FoodCountingScreen(),
    routePath[RouterPath.foodReceipt] ?? foodReceiptPath: (context) =>
        const FoodReceiptScreen(),
  };

  static void move<RoutingArguments extends Object>(
    BuildContext context, {
    required RouterPath to,
    RoutingArguments? arguments,
  }) {
    Navigator.pushNamed(
      context,
      routePath[to]!,
      arguments: arguments,
    );
  }

  static void back(BuildContext context) {
    Navigator.pop(context);
  }
}
