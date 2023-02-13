import 'package:app/providers/providers.dart';
import 'package:app/router/app_router.dart';
import 'package:flutter/material.dart';

void main() {
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
        initialRoute: AppRouter.initialRoute,
      ),
    );
  }
}
