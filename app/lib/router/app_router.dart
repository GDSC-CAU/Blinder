import 'package:app/screens/food_menu_board.dart';
import 'package:app/screens/food_scan_screen.dart';
import 'package:flutter/material.dart';

enum RouterPath {
  foodMenuBoard,
  foodMenuScan,
}

class AppRouter {
  const AppRouter();

  static const String foodMenuScanPath = "/menu-scan";
  static const String foodMenuPath = "/food-menu";

  static const Map<RouterPath, String> routePath = {
    RouterPath.foodMenuScan: foodMenuScanPath,
    RouterPath.foodMenuBoard: foodMenuPath,
  };

  static const Widget initialScreen = FoodScanScreen();

  static final Map<String, Widget Function(BuildContext)> routes = {
    routePath[RouterPath.foodMenuScan] ?? foodMenuScanPath: (context) =>
        const FoodScanScreen(),
    routePath[RouterPath.foodMenuBoard] ?? foodMenuPath: (context) =>
        const FoodMenuBoard(),
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
