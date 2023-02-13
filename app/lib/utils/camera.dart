import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

enum CameraStatus {
  error,
  success,
  loading,
  destroyed,
}

class AppCameraController {
  static CameraStatus status = CameraStatus.loading;

  final List<CameraDescription> cameras;
  final CameraController controller;
  final ResolutionPreset resolution;
  final ImageFormatGroup? imageFormatGroup;

  static AppCameraController? _instance;

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
  }) : controller = createCameraController(
          cameras: cameras,
          resolution: resolution,
          cameraSelectionIndex: cameraSelectionIndex <= cameras.length
              ? cameraSelectionIndex
              : throw Exception(
                  "Choose camera index in range ${cameras.length}",
                ),
          imageFormatGroup: imageFormatGroup,
        );

  static CameraController createCameraController({
    required List<CameraDescription> cameras,
    required ResolutionPreset resolution,
    int cameraSelectionIndex = 0,
    ImageFormatGroup? imageFormatGroup,
  }) {
    status = CameraStatus.loading;

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

  void destroyController() {
    status = CameraStatus.destroyed;
    controller.dispose();
    controller.debugCheckIsDisposed();
  }

  void initializeCamera(FutureOr<dynamic> Function(void) initializer) {
    controller.initialize().then(
      (_) {
        status = CameraStatus.success;
        initializer(_);
      },
    ).catchError(
      (Object error) {
        if (error is CameraException) {
          status = CameraStatus.error;

          switch (error.code) {
            case 'CameraAccessDenied':
              print("CAMERA: CameraAccessDenied, ${error.code}");
              break;
            // ios
            case "CameraAccessDeniedWithoutPrompt":
              print("CAMERA: CameraAccessDeniedWithoutPrompt, ${error.code}");
              break;
            // ios
            case "CameraAccessRestricted":
              print("CAMERA: CameraAccessRestricted");
              break;
            // another error
            default:
              throw Exception("Unknown error: ${error.code}");
          }
        }
      },
    );
  }
}

late AppCameraController appCameraController;

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
