import 'dart:async';
import 'dart:io';

import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:app/common/widgets/screen_title.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CropTestPage extends StatefulWidget {
  const CropTestPage({super.key});

  @override
  State<CropTestPage> createState() => _CropTestPageState();
}

class _CropTestPageState extends State<CropTestPage> {
  String _storagePath = '';
  String _imagePath = '';

  Future<void> detectObject() async {
    final _newImagePath = join(_storagePath,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
    await EdgeDetection.detectEdge(_newImagePath);
    setState(() {
      _imagePath = _newImagePath;
    });
  }

  Future<void> decideImagePath() async {
    _storagePath = (await getTemporaryDirectory()).path;
  }

  @override
  void initState() {
    decideImagePath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MenuButton(
                onPressed: detectObject,
                text: 'Scan Object',
              ),
            ),
            const SizedBox(height: 20),
            const ScreenTitle(title: 'Cropped image path:'),
            Padding(
              padding: const EdgeInsets.only(),
              child: Text(
                _imagePath,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            if (_imagePath != '')
              SizedBox(
                width: 300,
                height: 300,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image.file(
                    File(_imagePath),
                  ),
                ),
              )
            else
              Container(),
          ],
        ),
      ),
    );
  }
}
