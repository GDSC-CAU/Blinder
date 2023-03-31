import 'dart:async';

import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/core/menu_engine.dart';
import 'package:app/ml/object_detector_camera.dart';
import 'package:app/ml/object_painter.dart';
import 'package:app/providers/food_menu_provider.dart';
import 'package:app/router/app_router.dart';
import 'package:app/utils/camera.dart';
import 'package:app/utils/tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class FoodMenuDetect extends StatefulWidget {
  /// Target capture and retention time conditions
  final int capturingDuration;

  const FoodMenuDetect({
    required this.capturingDuration,
  });

  @override
  State<FoodMenuDetect> createState() => _ObjectDetectorView();
}

enum ObjectDetectorState {
  beforeInitialized,
  initialized,
  error,
}

enum MenuBoardDetectProcessState {
  process,
  capturing,
  success,
}

enum DeviceOrientation {
  /// `0`deg, center
  middle0Deg,

  /// `+90`deg, right
  ccw90Deg,

  /// `-90`deg, left
  cw90Deg,
}

class _ObjectDetectorView extends State<FoodMenuDetect> {
  final MenuEngine menuEngine = MenuEngine();
  late final ObjectDetector _objectDetector;

  DeviceOrientation? _deviceOrientation;
  late final StreamSubscription<AccelerometerEvent>
      _accelerometerStreamSubscription;

  ObjectDetectorState _objectDetectorState =
      ObjectDetectorState.beforeInitialized;

  CustomPaint? _customPaint;

  MenuBoardDetectProcessState _menuBoardDetectProcessState =
      MenuBoardDetectProcessState.process;

  bool _isDetectProcessing = false;
  bool _isOrientationCorrect = false;
  bool _isMenuBoardCapturingProcessing = false;
  bool _isOrientationCheckingProcessing = false;
  bool _isSimilarObjectCapturingProcessing = false;

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

  /// `X` acc (near gravity) = `+90`deg, `ccw90deg`
  ///
  /// `X` acc (near gravity) = `-90`deg, `cw90deg`
  ///
  /// `Y` acc (near gravity) = `0`deg, `middle0deg`
  void _updateDeviceOrientationByAccelerometer({
    required double xAcc,
    required double yAcc,
  }) {
    const halfGravity = 9.81 / 2;
    final isNotRotated = yAcc.abs() > xAcc.abs();
    if (isNotRotated) {
      _deviceOrientation = DeviceOrientation.middle0Deg;
      return;
    }

    if (xAcc > halfGravity) {
      _deviceOrientation = DeviceOrientation.ccw90Deg;
      return;
    }

    _deviceOrientation = DeviceOrientation.cw90Deg;
  }

  @override
  void initState() {
    super.initState();

    _initializeMenuBoardDetector().then((_) {
      _accelerometerStreamSubscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _updateDeviceOrientationByAccelerometer(
              xAcc: event.x,
              yAcc: event.y,
            );
          });
        },
      );
    });
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
    switch (_menuBoardDetectProcessState) {
      case MenuBoardDetectProcessState.process:
        return ObjectDetectorCamera(
          handleVideoImage: (videoImage) async {
            await _handleDetection(
              context: context,
              videoImage: videoImage,
            );
          },
          customPaint: _customPaint,
        );

      case MenuBoardDetectProcessState.capturing:
        return const CapturingProcess();

      case MenuBoardDetectProcessState.success:
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

  Future<void> _initializeMenuBoardDetector() async {
    const modelName = 'menu-detector';

    final response =
        await FirebaseObjectDetectorModelManager().downloadModel(modelName);
    print('Downloaded: $response');
    final options = FirebaseObjectDetectorOptions(
      mode: DetectionMode.stream,
      modelName: modelName,
      classifyObjects: true,
      multipleObjects: true,
    );

    _objectDetector = ObjectDetector(options: options);
    _objectDetectorState = ObjectDetectorState.initialized;
  }

  Future<String?> _getCapturedImagePath() async {
    if (AppCameraController.status != CameraStatus.destroyed &&
        AppCameraController.status != CameraStatus.waitForInitialization) {
      await appCameraController.controller.stopImageStream();

      final XFile capturedImageFile =
          await appCameraController.controller.takePicture();
      return capturedImageFile.path;
    }
    return null;
  }

  Future<void> _checkIsOrientationCorrect() async {
    _isOrientationCheckingProcessing = true;

    if (_deviceOrientation == DeviceOrientation.middle0Deg) {
      _isOrientationCorrect = true;
      _isOrientationCheckingProcessing = false;
      return;
    }

    await Future.delayed(const Duration(seconds: 2));
    await tts.speak("핸드폰을 세워주세요!");

    _isOrientationCorrect = false;
    _isOrientationCheckingProcessing = false;
  }

  void _resetVideoProcess() {
    setState(() {
      _menuBoardDetectProcessState = MenuBoardDetectProcessState.process;

      _isDetectProcessing = false;
      _isOrientationCorrect = false;
      _isMenuBoardCapturingProcessing = false;
      _isOrientationCheckingProcessing = false;
      _isSimilarObjectCapturingProcessing = false;
    });
  }

  Future<void> _handleDetection({
    required BuildContext context,
    required InputImage? videoImage,
  }) async {
    if (videoImage == null) return;

    if (_isMenuBoardCapturingProcessing) return;

    if (_menuBoardDetectProcessState == MenuBoardDetectProcessState.capturing ||
        _menuBoardDetectProcessState == MenuBoardDetectProcessState.success) {
      return;
    }

    if (_isOrientationCheckingProcessing == false) {
      await _checkIsOrientationCorrect();
    }

    if (_isOrientationCorrect == false) return;

    if (_isSimilarObjectCapturingProcessing) {
      await detectMenuBoard(videoImage);
      return;
    }

    const detectedMessageCondition = 15;
    if (_detectionStream.length == detectedMessageCondition) {
      _isSimilarObjectCapturingProcessing = true;
      await tts.speak("메뉴판으로 추정되는 물체를 발견했습니다!");
      _isSimilarObjectCapturingProcessing = false;
    } else {
      _isSimilarObjectCapturingProcessing = false;
    }

    if (_isFullyCaptured) {
      _isMenuBoardCapturingProcessing = true;

      await tts.speak("메뉴판을 발견했습니다! 잠시 고정해주세요.");

      setState(() {
        _menuBoardDetectProcessState = MenuBoardDetectProcessState.capturing;
      });

      final capturedImagePath = await _getCapturedImagePath();

      if (capturedImagePath == null) {
        _resetVideoProcess();
        return;
      }

      // remove object detector
      await _objectDetector.close();
      // cancel sensor subscription
      await _accelerometerStreamSubscription.cancel();

      await tts.speak("메뉴를 만들고 있습니다! 잠시만 기다려주세요");
      await menuEngine.parse(capturedImagePath);

      Provider.of<FoodMenuProvider>(
        context,
        listen: false,
      ).updateFoodMenu(
        menuEngine.foodMenu,
      );

      AppRouter.move(
        context,
        to: RouterPath.foodMenuBoard,
      );

      setState(() {
        _menuBoardDetectProcessState = MenuBoardDetectProcessState.success;
        _detectionStream = [];
        _resetVideoProcess();
      });
    } else {
      await detectMenuBoard(videoImage);
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
    await tts.speak("사진을 촬영 중입니다, 핸드폰을 움직이 말아주세요!");
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
