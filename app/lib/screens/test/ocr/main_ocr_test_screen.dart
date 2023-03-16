import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:app/screens/food_scan_screen.dart';
import 'package:flutter/material.dart';

class MainOcrTestScreen extends StatelessWidget {
  const MainOcrTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              text: 'OCR Test',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoodScanScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
