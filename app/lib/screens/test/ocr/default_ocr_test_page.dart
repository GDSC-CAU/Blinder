import 'package:app/common/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class DefaultOcrTestPage extends StatefulWidget {
  const DefaultOcrTestPage({super.key});

  @override
  State<DefaultOcrTestPage> createState() => _DefaultOcrTestPageState();
}

class _DefaultOcrTestPageState extends State<DefaultOcrTestPage> {
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
