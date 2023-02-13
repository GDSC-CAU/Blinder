import 'package:app/common/styles/colors.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
  });

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.$brown900,
        centerTitle: true,
        title: const Text(
          "Blinder",
          style: TextStyle(
            color: Palette.$brown100,
            fontWeight: FontWeight.w700,
            fontFamily: "Jura",
          ),
        ),
      ),
      body: Center(child: body),
    );
  }
}
