import 'package:app/ml/captured_image.dart';
import 'package:app/ml/object_detector.dart';
import 'package:app/providers/providers.dart';
import 'package:app/utils/camera.dart';
import 'package:app/utils/tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> setupPackages() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initTts();
  await initializeCameraInstance(
    resolution: ResolutionPreset.max,
    imageFormatGroup: ImageFormatGroup.yuv420,
  );
}

Future<void> main() async {
  await setupPackages();

  runApp(const Blinder());
}

class Blinder extends StatelessWidget {
  const Blinder({super.key});

  @override
  Widget build(BuildContext context) {
    return Providers(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Blinder",
        // routes: AppRouter.routes,
        // home: AppRouter.initialScreen,
        // initialRoute: AppRouter.mainVoicePath,
        routes: {
          '/': (context) => const ObjectDetectorView(
                executionFrameRate: 3,
                capturingDuration: 2,
              ),
          '/captured_image': (context) => const CapturedImageScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}
