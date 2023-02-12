import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';

import '../../common/widgets/menu_button.dart';

class TtsTestPage extends StatelessWidget {
  const TtsTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: MenuButton(
      onPressed: () async {
        speak('피자 볶음밥 치킨 핫도그 햄버거 초밥 돈가스');
      },
      text: 'Speak',
    ));
  }
}
