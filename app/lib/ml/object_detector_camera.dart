import 'dart:async';

import 'package:app/utils/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class ObjectDetectorCamera extends StatefulWidget {
  final CustomPaint? customPaint;
  final void Function(InputImage? videoImage) handleVideoImage;
  final CameraLensDirection initialDirection;

  /// execution `ML` model, in certain frame rate
  ///
  /// ex) `3`: `60`FPS/s / `3` = `20`FPS/s
  final int executionFrameRate;

  const ObjectDetectorCamera({
    required this.customPaint,
    required this.handleVideoImage,
    required this.executionFrameRate,
    this.initialDirection = CameraLensDirection.back,
  });

  @override
  State<ObjectDetectorCamera> createState() => _ObjectDetectorCameraState();
}

class _ObjectDetectorCameraState extends State<ObjectDetectorCamera> {
  bool _isCameraInitialized = false;
  int _videoStreamFrameCount = 0;

  @override
  void initState() {
    super.initState();

    _startVideo();
  }

  @override
  void dispose() {
    _stopVideo();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _videoView(),
    );
  }

  Widget _videoView() {
    if (_isCameraInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    var scale =
        size.aspectRatio * appCameraController.controller.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(
                appCameraController.controller,
              ),
            ),
          ),
          if (widget.customPaint != null) widget.customPaint!,
        ],
      ),
    );
  }

  void _startVideo() {
    appCameraController.initializeCamera(
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

  Future<void> _stopVideo() async {
    await appCameraController.controller.stopImageStream();

    appCameraController.destroyController();
  }

  void _processVideoImage(CameraImage image) {
    _videoStreamFrameCount += 1;

    final isSkipCurrentFrame =
        _videoStreamFrameCount % widget.executionFrameRate != 0;
    if (isSkipCurrentFrame) {
      widget.handleVideoImage(null);
      return;
    }

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
      widget.handleVideoImage(null);
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
      widget.handleVideoImage(null);
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

    widget.handleVideoImage(inputImage);

    _videoStreamFrameCount = 0;
  }
}
