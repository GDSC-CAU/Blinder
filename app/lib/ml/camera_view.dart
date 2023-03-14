import 'dart:async';

import 'package:app/utils/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class CameraView extends StatefulWidget {
  final CustomPaint? customPaint;
  final void Function(InputImage videoImage) handleImage;
  final CameraLensDirection initialDirection;

  const CameraView({
    required this.customPaint,
    required this.handleImage,
    this.initialDirection = CameraLensDirection.back,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  Timer? _timer;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();

    _startVideo();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (true) {
          _timer?.cancel();
          Timer(
            const Duration(seconds: 1),
            () {
              Navigator.of(context).pushNamed("/captured_image");
            },
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _stopVideo();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _liveFeedWidget(),
    );
  }

  Widget _liveFeedWidget() {
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
        children: <Widget>[
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
    if (imageRotation == null) return;

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

    if (inputImageFormat == null) return;

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

    widget.handleImage(inputImage);
  }
}
