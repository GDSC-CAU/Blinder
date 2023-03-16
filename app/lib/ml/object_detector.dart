import 'dart:async';
import 'dart:io' as io;

import 'package:app/ml/object_detector_camera.dart';
import 'package:app/ml/object_painter.dart';
import 'package:app/router/app_router.dart';
import 'package:app/utils/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

enum ObjectDetectorState {
  beforeInitialized,
  initialized,
  error,
}

class ObjectDetectorView extends StatefulWidget {
  /// execution `ML` model, in certain frame rate
  ///
  /// ex) `3`: `60`FPS/s / `3` = `20`FPS/s
  final int executionFrameRate;

  /// Target capture and retention time conditions
  final int capturingDuration;

  const ObjectDetectorView({
    required this.executionFrameRate,
    required this.capturingDuration,
  });

  @override
  State<ObjectDetectorView> createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorView> {
  late final ObjectDetector _objectDetector;

  ObjectDetectorState _objectDetectorState =
      ObjectDetectorState.beforeInitialized;

  CustomPaint? _customPaint;

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
    const originalExecutionPerSecond = 60;
    final framePerSecond =
        originalExecutionPerSecond / widget.executionFrameRate;
    return _detectionStream.length >= framePerSecond * widget.capturingDuration;
  }

  static const targetLabel = "menu_board";

  @override
  void initState() {
    super.initState();

    _initializeMenuBoardDetector();
  }

  @override
  void dispose() {
    _objectDetector.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ObjectDetectorCamera(
      handleVideoImage: (videoImage) async {
        await _handleDetection(
          videoImage: videoImage,
          context: context,
        );
      },
      customPaint: _customPaint,
      executionFrameRate: widget.executionFrameRate,
    );
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

  Future<void> _captureImage(
    BuildContext context,
  ) async {
    if (AppCameraController.status == CameraStatus.initialized) {
      final XFile capturedImage =
          await appCameraController.controller.takePicture();

      await _objectDetector.close();

      AppRouter.move(
        context,
        to: RouterPath.foodMenuBoard,
        arguments: capturedImage.path,
      );
    }
  }

  Future<void> _handleDetection({
    required BuildContext context,
    required InputImage? videoImage,
  }) async {
    if (videoImage == null) return;

    await detectMenuBoard(videoImage);

    if (_isFullyCaptured) {
      await _captureImage(context);
    }
  }

  /// ML detecting by image stream, [InputImage]
  Future<void> detectMenuBoard(
    InputImage inputImage,
  ) async {
    if (_objectDetectorState == ObjectDetectorState.error) return;

    if (_isDetectProcessing == true) return;
    _isDetectProcessing = true;

    try {
      final isInputImageLost = inputImage.inputImageData?.size == null ||
          inputImage.inputImageData?.imageRotation == null;

      if (isInputImageLost) {
        setState(() {
          _updateDetectionStream(false);
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
        setState(() {
          _updateDetectionStream(false);
        });
        return;
      }

      final menuBoardPainter = ObjectDetectorPainter(
        detectedObjectList: targetObjectList,
        rotation: inputImage.inputImageData!.imageRotation,
        absoluteSize: inputImage.inputImageData!.size,
        color: Colors.green.shade300,
        strokeWidth: 5,
      );

      setState(() {
        _customPaint = CustomPaint(
          painter: menuBoardPainter,
        );
        _updateDetectionStream(true);
      });
    } catch (mlError) {
      print(mlError);

      _objectDetectorState = ObjectDetectorState.error;
      return;
    }

    _isDetectProcessing = false;
    return;
  }
}
