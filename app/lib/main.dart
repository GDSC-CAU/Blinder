import 'package:app/providers/providers.dart';
import 'package:app/screens/main_voice_screen.dart';
import 'package:app/screens/test/tflite_model/tflite_model_test_screen.dart';
import 'package:app/utils/camera.dart';
import 'package:app/utils/tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> setupPackages() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initTts();
  await initializeCameraInstance(
    resolution: ResolutionPreset.max,
  );
  appCameraController.destroyController();
}

Future<void> main() async {
  await setupPackages();

  runApp(const Blinder());
}

class Blinder extends StatelessWidget {
  const Blinder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Providers(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Blinder",
        // routes: AppRouter.routes,
        // home: AppRouter.initialScreen,
        // initialRoute: AppRouter.mainVoicePath,
        home: MainVoiceScreen(),
      ),
    );
  }
}
