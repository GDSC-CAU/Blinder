import 'dart:async';

import 'package:app/utils/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class ObjectDetectorCamera extends StatefulWidget {
  final CustomPaint? customPaint;
  final Future<void> Function(InputImage? videoImage) handleVideoImage;
  final CameraLensDirection initialDirection;

  const ObjectDetectorCamera({
    required this.customPaint,
    required this.handleVideoImage,
    this.initialDirection = CameraLensDirection.back,
  });

  @override
  State<ObjectDetectorCamera> createState() => _ObjectDetectorCameraState();
}

class _ObjectDetectorCameraState extends State<ObjectDetectorCamera> {
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _startVideo(),
      builder: (context, snapshot) => Scaffold(
        body: _videoView(),
      ),
    );
  }

  Widget _videoView() {
    if (_isCameraInitialized == false) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "카메라 controller 초기화 중...",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            CircularProgressIndicator(
              color: Colors.red,
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: CameraPreview(
              appCameraController.controller,
            ),
          ),
          if (widget.customPaint != null) widget.customPaint!,
        ],
      ),
    );
  }

  Future<void> _startVideo() async {
    if (_isCameraInitialized ||
        AppCameraController.status == CameraStatus.destroyed ||
        AppCameraController.status == CameraStatus.initialized) return;

    await appCameraController.initializeCamera(
      (_) async {
        if (mounted) {
          await appCameraController.controller.startImageStream(
            _processVideoImage,
          );
          setState(() {
            _isCameraInitialized = true;
          });
        }
      },
    );
  }

  Future<void> _processVideoImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();

    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final imageRotation = InputImageRotationValue.fromRawValue(
      appCameraController.cameras.first.sensorOrientation,
    );
    if (imageRotation == null) {
      await widget.handleVideoImage(null);
      return;
    }

    final InputImageFormat? inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw as int);

    final planeData = image.planes
        .map(
          (Plane plane) => InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          ),
        )
        .toList();

    if (inputImageFormat == null) {
      await widget.handleVideoImage(null);
      return;
    }

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      inputImageData: inputImageData,
    );

    await widget.handleVideoImage(inputImage);
  }
}
