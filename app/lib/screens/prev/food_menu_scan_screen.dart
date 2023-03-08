import 'dart:io';

import 'package:app/common/widgets/bottom_button.dart';
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

  void moveToFoodCategory() {
    // AppRouter.move(
    //   context,
    //   to: RouterPath.foodCategory,
    // );
    appCameraController.destroyController();
  }

  Future<void> captureMenuBoardImage() async {
    final capturedImage = await appCameraController.controller.takePicture();

    setState(() {
      _capturedImage = File(capturedImage.path);
      _isCaptured = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (AppCameraController.status == CameraStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        appCameraController.destroyController();
        return true;
      },
      child: Scaffold(
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
                      onPressed: moveToFoodCategory,
                    )
                  ],
                )
              : Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      width: screenSize.width,
                      height: screenSize.height,
                      child: CameraPreview(
                        appCameraController.controller,
                      ),
                    ),
                    BottomButton(
                      text: "매뉴판 촬영 하기",
                      onPressed: captureMenuBoardImage,
                    ),
                  ],
                ),
        ),
      ),
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
