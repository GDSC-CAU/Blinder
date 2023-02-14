// Page in which user determines whether to add menu or order

import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:app/common/widgets/screen_title.dart';
import 'package:app/router/app_router.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';

class FoodOrderScreen extends StatelessWidget {
  const FoodOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ttsController.speak('메뉴를 선택하셨습니다. 음식을 추가할 지, 주문을 완료할지 선택하세요.');

    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ScreenTitle(title: '주문을 진행할까요?'),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                MenuButton(
                  text: '음식 주문',
                  onPressed: () {
                    AppRouter.move(
                      context,
                      to: RouterPath.foodReceipt,
                    );
                  },
                ),
                const SizedBox(height: 50),
                MenuButton(
                  text: '음식 추가',
                  onPressed: () {
                    AppRouter.moveAndClear(
                      context,
                      to: RouterPath.foodCategory,
                      clearRouterStackUntil: (route) =>
                          route.settings.name == AppRouter.foodMenuScanPath,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
