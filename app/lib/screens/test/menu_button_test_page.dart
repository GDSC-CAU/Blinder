import 'package:app/common/styles/colors.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:app/common/widgets/screen_layout.dart';
import 'package:app/providers/food_map_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuButtonTestPage extends StatelessWidget {
  const MenuButtonTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<FoodMapProvider>();
    controller.updateFoodMapFromJson(
      [
        {
          "category": "pasta2",
          "menu": [
            {"name": "멜팅 스테이크 파스타", "price": "17000"},
            {"name": "미트소스 파스타", "price": "15000"},
            {"name": "까르보라나 파스타", "price": "15000"},
            {"name": "매뉴 변경함", "price": "215000"},
          ]
        },
        {
          "category": "salad3",
          "menu": [
            {"name": "채식 샐러드", "price": "7000"},
            {"name": "닭가슴살 샐러드", "price": "8000"}
          ]
        }
      ],
    );
    return ScreenLayout(
        onPressed: () {
          Navigator.of(context).pop();
        },
        routeText: "이전으로",
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MenuButton(
                text: 'Menu Button',
                onPressed: () {
                  print(controller.getFoodCategory());
                },
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
          ),
        ]);
  }
}
