import 'package:app/common/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class TtsTestPage extends StatelessWidget {
  const TtsTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: ElevatedButton(
      onPressed: () {},
      child: const Text('Speak'),
    ));
  }
}
