import 'package:app/common/widgets/screen_layout.dart';
import 'package:app/router/app_router.dart';
import 'package:flutter/material.dart';

class MainVoiceScreen extends StatelessWidget {
  const MainVoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenLayout(
      onPressed: () {
        AppRouter.move(
          context,
          to: RouterPath.foodCamera,
        );
      },
      routeText: "메뉴판 촬영",
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.settings_voice,
                  size: 100,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "음식점 이름을\n알려주세요",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
