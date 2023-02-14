import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:image_picker/image_picker.dart';

class DefaultOcrTestPage extends StatefulWidget {
  const DefaultOcrTestPage({super.key});

  @override
  State<DefaultOcrTestPage> createState() => _DefaultOcrTestPageState();
}

class _DefaultOcrTestPageState extends State<DefaultOcrTestPage> {
  var extractedText = 'OCR 추출하기';

  Future<void> _extractTextFromImage() async {
    final _pickedImage = await ImagePicker.platform.getImage(
      source: ImageSource.gallery,
    );

    if (_pickedImage != null) {
      print('선택한 이미지 경로: ${_pickedImage.path}');
      final _extractedText = await FlutterTesseractOcr.extractText(
        _pickedImage.path,
        language: 'kor+eng',
      );
      setState(() {
        extractedText = _extractedText;
      });
    } else {
      print('이미지 선택 중단');
    }
  }

  void extractTextFromImage() {}

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MenuButton(
            text: '이미지 고르기',
            onPressed: _extractTextFromImage,
          ),
          Text(extractedText),
        ],
      ),
    );
  }
}
