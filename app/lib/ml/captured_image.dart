import 'package:app/common/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class CapturedImageScreen extends StatefulWidget {
  const CapturedImageScreen({super.key});

  @override
  State<CapturedImageScreen> createState() => _CapturedImageScreenState();
}

class _CapturedImageScreenState extends State<CapturedImageScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('거의 다 왔어유'),
        ],
      ),
    );
  }
}
