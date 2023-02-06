import 'package:app/screens/test/main_test_page.dart';
import 'package:flutter/material.dart';

import 'commons/styles/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.darkButtonColor,
            elevation: 0,
            foregroundColor: AppColor.lightButtonColor,
            fixedSize: const Size(300, 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(fontSize: 30),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainTestPage(),
    );
  }
}
