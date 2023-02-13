import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:app/common/widgets/screen_title.dart';
import 'package:app/providers/food_map_provider.dart';
import 'package:app/router/app_router.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodMenuScreen extends StatelessWidget {
  const FoodMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedFoodCategory =
        // ignore: cast_nullable_to_non_nullable
        ModalRoute.of(context)!.settings.arguments as String;
    final foodList = Provider.of<FoodMapProvider>(context)
        .getFoodMenuByCategory(selectedFoodCategory);

    final listHeight =
        MediaQuery.of(context).size.height - AppBar().preferredSize.height - 55;

    ttsController.speak("$selectedFoodCategory를 선택하셨습니다, 이제 원하는 음식을 선택해주세요");

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ScreenTitle(title: "음식 선택"),
            SizedBox(
              height: listHeight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final food = foodList[index];
                    return MenuButton(
                      text: "${food.name}, ${food.price}원",
                      onPressed: () {
                        AppRouter.move(
                          context,
                          to: RouterPath.foodCounting,
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            food.name,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "${food.price}원",
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: foodList.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
