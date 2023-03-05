import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:app/core/menu_engine.dart';
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
  Status status = Status.wait;
  String? menu;

  final menuEngine = MenuEngine();

  Future<void> _getFoodMenu() async {
    final pickedImage = await ImagePicker.platform.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      status = Status.loading;
    });

    if (pickedImage == null) {
      return;
    }

    final menuBoardImage = InputImage.fromFilePath(pickedImage.path);
    await menuEngine.parse(menuBoardImage);

    setState(() {
      status = Status.success;
      menu = menuEngine.foodMenu.fold(
        "",
        (previousValue, element) =>
            "$previousValue\n ${element.name}: ${element.price}",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              text: '이미지 고르기',
              onPressed: _getFoodMenu,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                status == Status.success ? "실행 성공\n$menu" : "로딩중",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                locale: const Locale('kr'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
