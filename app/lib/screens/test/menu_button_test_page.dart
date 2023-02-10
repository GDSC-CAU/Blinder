import 'package:flutter/material.dart';

import '../../commons/styles/colors.dart';
import '../../commons/widgets/default_scaffold.dart';
import '../../commons/widgets/menu_button.dart';

class MenuButtonTestPage extends StatelessWidget {
  const MenuButtonTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MenuButton(
            buttonName: 'Menu Button',
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.lightButtonColor),
            child: const Text(
              'Bottom Button',
              style: TextStyle(
                color: AppColor.darkButtonColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
