import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:app/screens/test/ocr/default_ocr_test_page.dart';
import 'package:app/screens/test/ocr/monochrome_ocr_test_page.dart';
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
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DefaultOcrTestPage()));
              },
            ),
            MenuButton(
              text: 'Monochrome OCR Test',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MonochromeOcrTestPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
