import 'package:app/common/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class DetectionTestScreen extends StatefulWidget {
  const DetectionTestScreen({super.key});

  @override
  State<DetectionTestScreen> createState() => _DetectionTestScreenState();
}

class _DetectionTestScreenState extends State<DetectionTestScreen> {
  String? result = 'Detect Image';

  Future<void> _initModel() async {
    await Tflite.loadModel(
      model: "assets/menu-detector.tflite",
      labels: "assets/label.txt",
    );
  }

  Future<void> _closeModel() async {
    await Tflite.close();
  }

  @override
  void initState() {
    _initModel();
    super.initState();
  }

  @override
  void dispose() {
    _closeModel();
    super.dispose();
  }

  void recognizeMenu() {
    Tflite.detectObjectOnImage(
      path: 'assets/test_image.jpg',
    ).then((value) {
      setState(() {
        result = value.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(result ?? 'Detect Image'),
          ElevatedButton(
            child: const Text('Detect Image'),
            onPressed: () {
              setState(() {
                recognizeMenu();
              });
            },
          ),
        ],
      ),
    );
  }
}
