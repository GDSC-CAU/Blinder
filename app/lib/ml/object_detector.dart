import 'dart:async';
import 'dart:io' as io;

import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/ml/object_detector_camera.dart';
import 'package:app/ml/object_painter.dart';
import 'package:app/utils/camera.dart';
import 'package:app/utils/tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ObjectDetectorView extends StatefulWidget {
  /// Target capture and retention time conditions
  final int capturingDuration;

  const ObjectDetectorView({
    required this.capturingDuration,
  });

  @override
  State<ObjectDetectorView> createState() => _ObjectDetectorView();
}

enum ObjectDetectorState {
  beforeInitialized,
  initialized,
  error,
}

enum MenuBoardDetectProcess {
  process,
  capturing,
  success,
}

class _ObjectDetectorView extends State<ObjectDetectorView> {
  late final ObjectDetector _objectDetector;

  ObjectDetectorState _objectDetectorState =
      ObjectDetectorState.beforeInitialized;

  CustomPaint? _customPaint;

  MenuBoardDetectProcess _menuBoardDetectProcess =
      MenuBoardDetectProcess.process;

  int _executionCount = 0;

  bool _isDetectProcessing = false;

  List<bool> _detectionStream = [];

  void _updateDetectionStream(bool targetExist) {
    if (targetExist) {
      _detectionStream.add(true);
      return;
    }
    _detectionStream = [];
    return;
  }

  /// If target is exists `capturingDuration` sec, `true`
  bool get _isFullyCaptured {
    const executionPerSecond = 60;
    const calculationSpeedRate = 0.5;

    return _detectionStream.length >=
        (executionPerSecond * widget.capturingDuration) * calculationSpeedRate;
  }

  static const targetLabel = "menu_board";

  @override
  void initState() {
    super.initState();
    _initializeMenuBoardDetector();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _objectDetectorView(context);
  }

  Widget _objectDetectorView(BuildContext context) {
    switch (_menuBoardDetectProcess) {
      case MenuBoardDetectProcess.process:
        return ObjectDetectorCamera(
          handleVideoImage: (videoImage) async {
            await _handleDetection(
              context: context,
              videoImage: videoImage,
            );
          },
          customPaint: _customPaint,
        );

      case MenuBoardDetectProcess.capturing:
        return const CapturingProcess();

      case MenuBoardDetectProcess.success:
        return const AppScaffold(
          body: Center(
            child: Text(
              "성공",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
    }
  }

  Future<String> _getModelPath(String assetPath) async {
    if (io.Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }

    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(
      recursive: true,
    );

    final file = io.File(path);

    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
    }

    return file.path;
  }

  Future<void> _initializeMenuBoardDetector() async {
    const modelSourcePath = 'assets/ml/menu-detector.tflite';
    final modelPath = await _getModelPath(modelSourcePath);

    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.stream,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
    );

    _objectDetector = ObjectDetector(
      options: options,
    );
    _objectDetectorState = ObjectDetectorState.initialized;
  }

  Future<String?> _getCapturedImagePath() async {
    if (AppCameraController.status != CameraStatus.destroyed &&
        AppCameraController.status != CameraStatus.waitForInitialization) {
      await appCameraController.controller.lockCaptureOrientation();
      await appCameraController.controller.stopImageStream();

      final XFile file = await appCameraController.controller.takePicture();

      return file.path;
    }
    return null;
  }

  Future<void> _handleDetection({
    required BuildContext context,
    required InputImage? videoImage,
  }) async {
    if (videoImage == null) {
      return;
    }

    if (_menuBoardDetectProcess == MenuBoardDetectProcess.capturing ||
        _menuBoardDetectProcess == MenuBoardDetectProcess.success) {
      return;
    }

    const detectedMessageCondition = 15;
    if (_detectionStream.length == detectedMessageCondition) {
      await ttsController.speak("메뉴판으로 추정되는 물체를 발견했습니다!");
    }

    if (_isFullyCaptured) {
      _executionCount++;
      if (_executionCount != 1) return;

      await ttsController.speak("메뉴판을 발견했습니다! 잠시 고정해주세요.");

      setState(() {
        _menuBoardDetectProcess = MenuBoardDetectProcess.capturing;
      });

      final imagePath = await _getCapturedImagePath();

      await _objectDetector.close();

      setState(() {
        _menuBoardDetectProcess = MenuBoardDetectProcess.success;
        _detectionStream = [];
      });

      Navigator.pushNamed(
        context,
        "/captured_image",
        arguments: imagePath,
      );
    } else {
      await detectMenuBoard(videoImage);
      setState(() {
        _menuBoardDetectProcess = MenuBoardDetectProcess.process;
      });
    }
  }

  /// ML detecting by image stream, [InputImage]
  Future<void> detectMenuBoard(
    InputImage inputImage,
  ) async {
    if (_objectDetectorState == ObjectDetectorState.beforeInitialized ||
        _objectDetectorState == ObjectDetectorState.error) return;

    if (_isDetectProcessing == true) return;
    _isDetectProcessing = true;

    try {
      final isInputImageLost = inputImage.inputImageData?.size == null ||
          inputImage.inputImageData?.imageRotation == null;

      if (isInputImageLost) {
        _updateDetectionStream(false);
        _isDetectProcessing = false;

        setState(() {
          _customPaint = null;
        });
        return;
      }

      final recognizedObjectList =
          await _objectDetector.processImage(inputImage);

      final targetObjectList = recognizedObjectList
          .where(
            (element) => element.labels.any(
              (label) => label.text == targetLabel,
            ),
          )
          .toList();
      if (targetObjectList.isEmpty) {
        _updateDetectionStream(false);
        _isDetectProcessing = false;

        setState(() {
          _customPaint = null;
        });
        return;
      }

      final menuBoardPainter = ObjectDetectorPainter(
        detectedObjectList: targetObjectList,
        rotation: inputImage.inputImageData!.imageRotation,
        absoluteSize: inputImage.inputImageData!.size,
        color: Colors.green.shade300,
        strokeWidth: 3,
      );

      _updateDetectionStream(true);
      _isDetectProcessing = false;

      setState(() {
        _customPaint = CustomPaint(
          painter: menuBoardPainter,
        );
      });
    } catch (mlError) {
      print(mlError);

      _objectDetectorState = ObjectDetectorState.error;
      _isDetectProcessing = false;

      setState(() {
        _customPaint = null;
      });
    }
  }
}

class CapturingProcess extends StatelessWidget {
  const CapturingProcess({
    super.key,
  });

  Future<void> _capturingGuide() async {
    await ttsController.speak("사진을 촬영 중입니다, 핸드폰을 움직이 말아주세요!");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _capturingGuide(),
      builder: (context, snapshot) => AppScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "메뉴판 촬영중...",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
