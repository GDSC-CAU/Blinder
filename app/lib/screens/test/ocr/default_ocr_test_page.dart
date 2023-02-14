import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
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
      final inputImage = InputImage.fromFilePath(_pickedImage.path);
      final textRecognizer = GoogleMlKit.vision
          .textRecognizer(script: TextRecognitionScript.korean);
      final recognisedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final scannedText = StringBuffer();

      for (final TextBlock block in recognisedText.blocks) {
        for (final TextLine line in block.lines) {
          scannedText.write('${line.text}\n');
        }
      }
      setState(() {
        extractedText = scannedText.toString();
      });
    } else {
      print('이미지 선택 중단');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              text: '이미지 고르기',
              onPressed: _extractTextFromImage,
            ),
            Text(extractedText),
          ],
        ),
      ),
    );
  }
}
