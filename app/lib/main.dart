import 'package:app/providers/providers.dart';
import 'package:app/router/app_router.dart';
import 'package:app/utils/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  initializeCameraInstance(
    resolution: ResolutionPreset.max,
  );

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
        routes: AppRouter.routes,
        home: AppRouter.initialScreen,
        initialRoute: AppRouter.mainVoicePath,
      ),
    );
  }
}
