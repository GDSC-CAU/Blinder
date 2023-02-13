import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';

import '../../common/widgets/menu_button.dart';

class TtsTestPage extends StatefulWidget {
  const TtsTestPage({super.key});

  @override
  State<TtsTestPage> createState() => _TtsTestPageState();
}

class _TtsTestPageState extends State<TtsTestPage> {
  @override
  void initState() {
    super.initState();
    ttsController.speak('페이지가 열렸습니다.');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: MenuButton(
      onPressed: () {},
      text: 'Speak',
    ));
  }
}
