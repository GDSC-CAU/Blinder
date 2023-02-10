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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Blinder",
              style: TextStyle(
                color: Palette.$white,
                fontWeight: FontWeight.w700,
                fontFamily: "",
              ),
            ),
            SizedBox(
              width: 7,
            ),
            Icon(
              Icons.remove_red_eye,
              color: Palette.$white,
              size: 20,
            ),
          ],
        ),
      ),
      body: Center(child: body),
    );
  }
}
