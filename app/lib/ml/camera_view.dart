import 'dart:io';

import 'package:app/utils/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    Key? key,
    required this.title,
    required this.customPaint,
    required this.onImage,
    this.text,
    this.initialDirection = CameraLensDirection.back,
  }) : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;

  @override
  void initState() {
    super.initState();

    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _liveFeedWidget(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget? _floatingActionButton() {
    if (appCameraController.cameras.length == 1) return null;
    return SizedBox(
      height: 70.0,
      width: 70.0,
      child: FloatingActionButton(
        onPressed: () {},
        child: Icon(
          Platform.isIOS
              ? Icons.flip_camera_ios_outlined
              : Icons.flip_camera_android_outlined,
          size: 40,
        ),
      ),
    );
  }

  Widget _liveFeedWidget() {
    if (appCameraController.controller.value.isInitialized == false) {
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
          Positioned(
            bottom: 100,
            left: 50,
            right: 50,
            child: Slider(
              value: zoomLevel,
              min: minZoomLevel,
              max: maxZoomLevel,
              onChanged: (newSliderValue) {
                setState(() {
                  zoomLevel = newSliderValue;
                  appCameraController.controller.setZoomLevel(zoomLevel);
                });
              },
              divisions: (maxZoomLevel - 1).toInt() < 1
                  ? null
                  : (maxZoomLevel - 1).toInt(),
            ),
          )
        ],
      ),
    );
  }

  Future _startLiveFeed() async {
    appCameraController.initializeCamera(
      (_) async {
        if (mounted) {
          await appCameraController.controller.getMinZoomLevel().then(
            (value) {
              zoomLevel = value;
              minZoomLevel = value;
            },
          );
          await appCameraController.controller.getMaxZoomLevel().then(
            (value) {
              maxZoomLevel = value;
            },
          );
          await appCameraController.controller
              .startImageStream(_processCameraImage);
        }
      },
    );
  }

  Future _stopLiveFeed() async {
    await appCameraController.controller.stopImageStream();
    appCameraController.destroyController();
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final imageRotation = InputImageRotationValue.fromRawValue(
      appCameraController.cameras.first.sensorOrientation,
    );
    if (imageRotation == null) return;

    if (image.format.raw is int) {
      final InputImageFormat? inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw as int);

      final planeData = image.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      if (inputImageFormat == null) return;

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      final inputImage =
          InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

      widget.onImage(inputImage);
    }
  }
}
