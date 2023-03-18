import 'dart:io';

import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/utils/camera.dart';
import 'package:flutter/material.dart';

class CapturedImageScreen extends StatefulWidget {
  const CapturedImageScreen({super.key});

  @override
  State<CapturedImageScreen> createState() => _CapturedImageScreenState();
}

class _CapturedImageScreenState extends State<CapturedImageScreen> {
  @override
  void initState() {
    super.initState();
    appCameraController.destroyController();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = ModalRoute.of(context)!.settings.arguments! as String;

    return AppScaffold(
      body: Center(
        child: Image.file(
          File(imagePath),
        ),
      ),
    );
  }
}
