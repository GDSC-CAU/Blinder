import 'package:app/common/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class MonochromeOcrTestPage extends StatefulWidget {
  const MonochromeOcrTestPage({super.key});

  @override
  State<MonochromeOcrTestPage> createState() => _MonochromeOcrTestPageState();
}

class _MonochromeOcrTestPageState extends State<MonochromeOcrTestPage> {
  var extractedText = 'OCR 추출하기';
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(extractedText),
        ],
      ),
    );
  }
}
