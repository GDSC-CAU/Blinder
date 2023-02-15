import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

enum Status {
  failed,
  loading,
  success,
  wait,
}

class _OcrScreenState extends State<OcrScreen> {
  var extractedText = 'OCR 추출하기';
  final List<String> scannedTextList = [];
  Status status = Status.wait;

  Future<void> _extractTextFromImage() async {
    scannedTextList.clear();

    final _pickedImage = await ImagePicker.platform.getImage(
      source: ImageSource.gallery,
    );

    if (_pickedImage != null) {
      setState(() {
        status = Status.loading;
      });
      final inputImage = InputImage.fromFilePath(_pickedImage.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer(
        script: TextRecognitionScript.korean,
      );
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      for (final TextBlock block in recognizedText.blocks) {
        for (final TextLine line in block.lines) {
          scannedTextList.add(line.text);
        }
      }
      setState(() {
        status = Status.success;
        extractedText = scannedTextList.reduce((value, text) => "$value $text");
      });

      await textRecognizer.close();
    } else {
      setState(() {
        status = Status.failed;
      });
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
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                status == Status.loading ? "로딩 중" : extractedText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                locale: const Locale('kr'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
