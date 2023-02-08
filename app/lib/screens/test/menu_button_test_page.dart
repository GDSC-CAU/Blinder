import 'package:app/common/styles/colors.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:flutter/material.dart';

class MenuButtonTestPage extends StatelessWidget {
  const MenuButtonTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MenuButton(
          text: 'Menu Button',
          onPressed: () {},
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Palette.$white,
          ),
          child: const Text(
            'Bottom Button',
            style: TextStyle(
              color: Palette.$brown700,
            ),
          ),
        ),
      ],
    );
  }
}
