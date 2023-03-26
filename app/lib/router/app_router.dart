import 'package:app/screens/food_menu_board.dart';
import 'package:app/screens/food_menu_detect.dart';
import 'package:app/screens/review_screen.dart';
import 'package:flutter/material.dart';

enum RouterPath {
  foodMenuBoard,
  foodMenuDetect,
  reviewScreen,
}

class AppRouter {
  const AppRouter();

  static const String foodMenuDetectPath = "/";
  static const String foodMenuBoardPath = "/food-menu-board";
  static const String reviewScreenPath = "/review";

  static const Map<RouterPath, String> routePath = {
    RouterPath.foodMenuDetect: foodMenuDetectPath,
    RouterPath.foodMenuBoard: foodMenuBoardPath,
    RouterPath.reviewScreen: reviewScreenPath,
  };

  static final Map<String, Widget Function(BuildContext)> routes = {
    routePath[RouterPath.foodMenuDetect] ?? foodMenuDetectPath: (context) =>
        const FoodMenuDetect(capturingDuration: 2),
    routePath[RouterPath.foodMenuBoard] ?? foodMenuBoardPath: (context) =>
        const FoodMenuBoard(),
    routePath[RouterPath.reviewScreen] ?? reviewScreenPath: (context) =>
        const ReviewScreen(),
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
