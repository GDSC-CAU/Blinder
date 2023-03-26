import 'package:app/common/styles/colors.dart';
import 'package:app/router/app_router.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;

  const AppScaffold({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.$brown900,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            icon: const Icon(
              Icons.reviews,
            ),
            onPressed: () => AppRouter.move(
              context,
              to: RouterPath.reviewScreen,
            ),
          ),
        ],
      ),
      body: Center(child: body),
    );
  }
}
