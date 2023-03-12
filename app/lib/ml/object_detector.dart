import 'dart:io' as io;

import 'package:app/ml/camera_view.dart';
import 'package:app/ml/object_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

enum ObjectDetectorState {
  beforeInitialized,
  initialized,
  destroyed,
  error,
}

class ObjectDetectorView extends StatefulWidget {
  @override
  State<ObjectDetectorView> createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorView> {
  late final ObjectDetector _objectDetector;

  bool _isDetectProcessing = false;

  ObjectDetectorState _objectDetectorState =
      ObjectDetectorState.beforeInitialized;

  CustomPaint? _customPaint;

  @override
  void initState() {
    super.initState();

    _initializeMenuBoardDetector();
  }

  @override
  void dispose() {
    _objectDetectorState = ObjectDetectorState.destroyed;
    _objectDetector.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      customPaint: _customPaint,
      handleImage: (videoImage) async {
        detectMenuBoard(videoImage);
      },
    );
  }

  Future<String> _getModelFromAsset(String assetPath) async {
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
    final modelPath = await _getModelFromAsset(modelSourcePath);

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

  /// ML detecting by image stream, [InputImage]
  Future<void> detectMenuBoard(
    InputImage inputImage,
  ) async {
    if (_objectDetectorState == ObjectDetectorState.destroyed ||
        _objectDetectorState == ObjectDetectorState.error) return;

    if (_isDetectProcessing == true) return;
    _isDetectProcessing = true;

    try {
      final recognizedObjectList =
          await _objectDetector.processImage(inputImage);

      final isInputImageExist = inputImage.inputImageData?.size != null &&
          inputImage.inputImageData?.imageRotation != null;

      if (isInputImageExist) {
        final painter = ObjectDetectorPainter(
          detectedObjectList: recognizedObjectList,
          rotation: inputImage.inputImageData!.imageRotation,
          absoluteSize: inputImage.inputImageData!.size,
        );
        _customPaint = CustomPaint(
          painter: painter,
        );
      }
    } catch (mlError) {
      print(mlError);
      _objectDetectorState = ObjectDetectorState.error;
    }

    _isDetectProcessing = false;
  }
}
