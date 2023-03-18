import 'package:app/ml/captured_image.dart';
import 'package:app/ml/object_detector.dart';
import 'package:flutter/material.dart';

enum RouterPath {
  foodMenuBoard,
  foodMenuDetect,
}

class AppRouter {
  const AppRouter();

  static const String foodMenuDetectPath = "/";
  static const String foodMenuBoardPath = "/food-menu-board";

  static const Map<RouterPath, String> routePath = {
    RouterPath.foodMenuDetect: foodMenuDetectPath,
    RouterPath.foodMenuBoard: foodMenuBoardPath,
  };

  static Widget initialScreen = const ObjectDetectorView(
    capturingDuration: 2,
  );

  static final Map<String, Widget Function(BuildContext)> routes = {
    routePath[RouterPath.foodMenuDetect] ?? foodMenuDetectPath: (context) =>
        initialScreen,
    routePath[RouterPath.foodMenuBoard] ?? foodMenuBoardPath: (context) =>
        const CapturedImageScreen(),
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
