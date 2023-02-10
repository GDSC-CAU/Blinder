import 'package:app/screens/test/main_test_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Blinder());
}

class Blinder extends StatelessWidget {
  const Blinder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainTestPage(),
    );
  }
}
