import 'package:app/providers/providers.dart';
import 'package:app/screens/test/main_test_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Blinder());
}

class Blinder extends StatelessWidget {
  const Blinder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Providers(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainTestPage(),
      ),
    );
  }
}
