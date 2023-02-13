import 'dart:io';

import 'package:app/common/widgets/bottom_button.dart';
import 'package:app/router/app_router.dart';
import 'package:app/utils/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FoodMenuScanScreen extends StatefulWidget {
  const FoodMenuScanScreen({super.key});

  @override
  State<FoodMenuScanScreen> createState() => _FoodMenuScanScreenState();
}

class _FoodMenuScanScreenState extends State<FoodMenuScanScreen> {
  bool _isCaptured = false;
  late File? _capturedImage;

  @override
  void initState() {
    super.initState();
    appCameraController.initializeCamera(
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (appCameraController.controller.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final viewSize = MediaQuery.of(context).size;
    final cameraViewWidth = viewSize.width;
    final cameraViewHeight = viewSize.height;

    return Scaffold(
      body: Center(
        child: _isCaptured
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CapturedImage(
                      imageFile: _capturedImage!,
                    ),
                  ),
                  BottomButton(
                    text: "음식 주문하기",
                    onPressed: () {
                      AppRouter.move(
                        context,
                        to: RouterPath.foodCategory,
                      );
                    },
                  )
                ],
              )
            : Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    width: cameraViewWidth,
                    height: cameraViewHeight,
                    child: CameraPreview(
                      appCameraController.controller,
                    ),
                  ),
                  FloatingActionCameraButton(
                    onPressed: () async {
                      final capturedImage =
                          await appCameraController.controller.takePicture();

                      _capturedImage = File(capturedImage.path);
                      setState(() {
                        _isCaptured = true;
                      });
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

class FloatingActionCameraButton extends StatelessWidget {
  final void Function() onPressed;

  const FloatingActionCameraButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomButton(
      text: "매뉴판 촬영 하기",
      onPressed: onPressed,
    );
  }
}

class CapturedImage extends StatelessWidget {
  final File imageFile;

  const CapturedImage({
    super.key,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.file(
        imageFile,
        height: 400,
      ),
    );
  }
}
