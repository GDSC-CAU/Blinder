import 'package:app/common/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

import '../../common/widgets/menu_button.dart';

class TtsTestPage extends StatelessWidget {
  const TtsTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: MenuButton(
      onPressed: () {},
      text: 'Speak',
    ));
  }
}
