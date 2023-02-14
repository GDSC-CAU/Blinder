import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/bottom_button.dart';
import 'package:app/common/widgets/screen_title.dart';
import 'package:app/models/food_cart_item.dart';
import 'package:app/models/food_menu.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/widgets/menu_button.dart';
import '../router/app_router.dart';

class FoodCountingScreen extends StatefulWidget {
  const FoodCountingScreen({super.key});

  @override
  State<FoodCountingScreen> createState() => _FoodCountingScreenState();
}

class _FoodCountingScreenState extends State<FoodCountingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final menu = ModalRoute.of(context)!.settings.arguments! as FoodMenu;
      ttsController.speak('${menu.name}을 선택하셨습니다. 메뉴 개수를 정해주세요.');
    });
  }

  var itemCnt = 0;

  // Item Count
  void increment() => setState(() {
        itemCnt++;
        ttsController.speak('추가하기. 현재 $itemCnt개 선택했습니다.');
      });

  void decrement() => setState(() {
        if (itemCnt > 0) {
          itemCnt--;
          ttsController.speak('빼기. 현재 $itemCnt개 선택했습니다.');
        } else {
          ttsController.speak('0개. 더 이상 뺄 수 없습니다.');
        }
      });

  @override
  Widget build(BuildContext context) {
    final menu = ModalRoute.of(context)!.settings.arguments! as FoodMenu;
    return AppScaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScreenTitle(
                  title: menu.name,
                ),
                ScreenTitle(
                  title: '$itemCnt개',
                ),
                const SizedBox(height: 50),
                MenuButton(
                  text: '추가하기',
                  onPressed: increment,
                ),
                const SizedBox(height: 30),
                MenuButton(
                  text: '빼기',
                  onPressed: decrement,
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: BottomButton(
              text: '장바구니에 담기',
              onPressed: () {
                // Count Validation
                if (itemCnt == 0) {
                  ttsController.speak('메뉴를 1개 이상 선택해주세요.');
                } else {
                  context.read<FoodCartProvider>().addItem(FoodCartItem(
                        name: menu.name,
                        price: menu.price,
                        count: itemCnt,
                      ));
                  AppRouter.move(
                    context,
                    to: RouterPath.foodOrder,
                    arguments: '',
                  );
                }
              },
            ),
          ),
        ),
      ],
    ));
  }
}
