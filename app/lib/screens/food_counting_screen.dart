import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/bottom_button.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';

import '../common/widgets/menu_button.dart';

class FoodCountingScreen extends StatefulWidget {
  const FoodCountingScreen({super.key});

  @override
  State<FoodCountingScreen> createState() => _FoodCountingScreenState();
}

class _FoodCountingScreenState extends State<FoodCountingScreen> {
  var itemCnt = 0;

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
    final menuName = ModalRoute.of(context)?.settings.arguments;
    return AppScaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              menuName.toString(),
            ),
            Text(
              '$itemCnt개',
            ),
            MenuButton(
              text: '추가하기',
              onPressed: increment,
            ),
            MenuButton(
              text: '빼기',
              onPressed: decrement,
            ),
          ],
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: BottomButton(
              text: '장바구니 담기',
              onPressed: () {},
            ),
          ),
        ),
      ],
    ));
  }
}
