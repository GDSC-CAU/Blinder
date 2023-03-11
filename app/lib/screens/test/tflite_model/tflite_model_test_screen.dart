import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/utils/camera.dart';
import 'package:flutter/material.dart';

class DetectionTestScreen extends StatefulWidget {
  const DetectionTestScreen({super.key});

  @override
  State<DetectionTestScreen> createState() => _DetectionTestScreenState();
}

class _DetectionTestScreenState extends State<DetectionTestScreen> {
  String? result = 'Detect Image';

  Future<void> _initModel() async {}

  @override
  void initState() {
    _initModel();
    appCameraController.initializeCamera(
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
    print('previewSize: $appCameraController.controller.value.previewSize');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> recognizeMenu() async {}

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    print(screenSize.toString());
    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(result ?? 'Detect Image'),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              maximumSize: const Size(300, 200),
            ),
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
