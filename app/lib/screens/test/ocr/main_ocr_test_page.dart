import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:flutter/material.dart';

class MainOcrTestPage extends StatelessWidget {
  const MainOcrTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              text: 'Default OCR Test',
              onPressed: () {},
            ),
            MenuButton(
              text: 'Monochrome OCR Test',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
