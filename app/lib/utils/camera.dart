import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

enum CameraStatus {
  error,
  waitForInitialization,
  initialized,
  destroyed,
}

class AppCameraController {
  static AppCameraController? _instance;
  static CameraStatus status = CameraStatus.waitForInitialization;

  final List<CameraDescription> cameras;
  CameraController controller;
  final ResolutionPreset resolution;
  final ImageFormatGroup? imageFormatGroup;

  factory AppCameraController({
    required List<CameraDescription> cameras,
    required ResolutionPreset resolution,
    int cameraSelectionIndex = 0,
    ImageFormatGroup? imageFormatGroup,
  }) {
    return _instance ??= AppCameraController._createSingleInstance(
      cameras: cameras,
      resolution: resolution,
      cameraSelectionIndex: cameraSelectionIndex,
      imageFormatGroup: imageFormatGroup,
    );
  }

  AppCameraController._createSingleInstance({
    required this.cameras,
    required this.resolution,
    int cameraSelectionIndex = 0,
    this.imageFormatGroup,
  }) : controller = _createCameraController(
          cameras: cameras,
          resolution: resolution,
          cameraSelectionIndex: cameraSelectionIndex <= cameras.length
              ? cameraSelectionIndex
              : throw Exception(
                  "Choose camera index in range ${cameras.length}",
                ),
          imageFormatGroup: imageFormatGroup,
        );

  static CameraController _createCameraController({
    required List<CameraDescription> cameras,
    required ResolutionPreset resolution,
    int cameraSelectionIndex = 0,
    ImageFormatGroup? imageFormatGroup,
  }) {
    if (cameras.isEmpty) {
      status = CameraStatus.error;
      throw Exception("There is no camera at connected device");
    }

    status = CameraStatus.waitForInitialization;
    return CameraController(
      cameras[cameraSelectionIndex],
      resolution,
      enableAudio: false,
      imageFormatGroup: imageFormatGroup,
    );
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      destroyController();
      return;
    }
  }

  Future<void> destroyController() async {
    await controller.dispose();
    controller.debugCheckIsDisposed();
    status = CameraStatus.destroyed;
  }

  Future<void> initializeCamera(
    FutureOr<dynamic> Function(void) initializer,
  ) async {
    try {
      if (status == CameraStatus.destroyed) {
        status = CameraStatus.waitForInitialization;
        controller = _createCameraController(
          cameras: cameras,
          resolution: resolution,
        );
      }
      await controller.initialize().then(initializer);
      status = CameraStatus.initialized;
    } catch (error) {
      status = CameraStatus.error;

      if (error is CameraException) {
        switch (error.code) {
          case 'CameraAccessDenied':
            throw Exception("CAMERA: CameraAccessDenied, ${error.code}");
          // ios
          case "CameraAccessDeniedWithoutPrompt":
            throw Exception(
                "CAMERA: CameraAccessDeniedWithoutPrompt, ${error.code}");
          // ios
          case "CameraAccessRestricted":
            throw Exception("CAMERA: CameraAccessRestricted");
          // another error
          default:
            throw Exception("Unknown error: ${error.code}");
        }
      }
    }
  }
}

late final AppCameraController appCameraController;

Future<void> initializeCameraInstance({
  required ResolutionPreset resolution,
  int cameraSelectionIndex = 0,
  ImageFormatGroup? imageFormatGroup,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  appCameraController = AppCameraController(
    cameras: await availableCameras(),
    resolution: resolution,
    cameraSelectionIndex: cameraSelectionIndex,
    imageFormatGroup: imageFormatGroup,
  );
}
