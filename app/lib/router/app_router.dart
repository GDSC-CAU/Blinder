import 'package:app/screens/food_category_screen.dart';
import 'package:app/screens/food_counting_screen.dart';
import 'package:app/screens/food_menu_scan_screen.dart';
import 'package:app/screens/food_menu_screen.dart';
import 'package:app/screens/food_order_screen.dart';
import 'package:app/screens/food_receipt_screen.dart';
import 'package:app/screens/main_voice_screen.dart';
import 'package:flutter/material.dart';

enum RouterPath {
  mainVoice,
  foodMenuScan,
  foodCategory,
  foodMenu,
  foodCounting,
  foodOrder,
  foodReceipt,
}

class AppRouter {
  const AppRouter();

  static const String mainVoicePath = "/";
  static const String foodMenuScanPath = "/scan";
  static const String foodCategoryPath = "/food-category";
  static const String foodCountingPath = "/food-counting";
  static const String foodMenuPath = "/food-menu";
  static const String foodOrderPath = "/food-order";
  static const String foodReceiptPath = "/food-receipt";

  static const Map<RouterPath, String> routePath = {
    RouterPath.mainVoice: mainVoicePath,
    RouterPath.foodMenuScan: foodMenuScanPath,
    RouterPath.foodCategory: foodCategoryPath,
    RouterPath.foodCounting: foodCountingPath,
    RouterPath.foodMenu: foodMenuPath,
    RouterPath.foodOrder: foodOrderPath,
    RouterPath.foodReceipt: foodReceiptPath,
  };

  static const Widget initialScreen = MainVoiceScreen();

  static final Map<String, Widget Function(BuildContext)> routes = {
    routePath[RouterPath.foodMenuScan] ?? foodMenuScanPath: (context) =>
        const FoodMenuScanScreen(),
    routePath[RouterPath.foodCategory] ?? foodCategoryPath: (context) =>
        const FoodCategoryScreen(),
    routePath[RouterPath.foodMenu] ?? foodMenuPath: (context) =>
        const FoodMenuScreen(),
    routePath[RouterPath.foodCounting] ?? foodCountingPath: (context) =>
        const FoodCountingScreen(),
    routePath[RouterPath.foodOrder] ?? foodOrderPath: (context) =>
        const FoodOrderScreen(),
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

  static void moveAndClear<RoutingArguments extends Object>(
    BuildContext context, {
    required RouterPath to,
    required bool Function(Route<dynamic>) clearRouterStackUntil,
    RoutingArguments? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routePath[to]!,
      (route) => clearRouterStackUntil(route),
      arguments: arguments,
    );
  }

  static void back(BuildContext context) {
    Navigator.pop(context);
  }
}
