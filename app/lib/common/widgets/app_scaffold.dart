import 'package:app/common/styles/colors.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palette.$brown900,
          centerTitle: true,
          actions: actions,
        ),
        body: Center(child: body),
      ),
    );
  }
}
