import 'package:app/providers/providers.dart';
import 'package:app/router/app_router.dart';
import 'package:app/services/firebase/analyst.dart';
import 'package:app/utils/camera.dart';
import 'package:app/utils/tts.dart';
import 'package:camera/camera.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> setupPackages() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initTts();
  await initializeCameraInstance(
    resolution: ResolutionPreset.max,
    imageFormatGroup: ImageFormatGroup.yuv420,
  );

  await appCameraController.destroyController();
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
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalyst.analytics),
        ],
        title: "Blinder",
        routes: AppRouter.routes,
        initialRoute: AppRouter.foodMenuDetectPath,
      ),
    );
  }
}
