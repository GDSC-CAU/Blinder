import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:app/providers/food_map_provider.dart';
import 'package:app/router/app_router.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodCategoryScreen extends StatelessWidget {
  const FoodCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ttsController.speak("원하는 음식의 카테고리를 선택하세요");

    final foodCategoryList = context.read<FoodMapProvider>().getFoodCategory();
    final height =
        MediaQuery.of(context).size.height - AppBar().preferredSize.height;

    return AppScaffold(
      body: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
            itemBuilder: (context, index) {
              final foodCategory = foodCategoryList[index];
              return MenuButton(
                text: foodCategory,
                onPressed: () {
                  AppRouter.move(
                    context,
                    to: RouterPath.foodMenu,
                    arguments: foodCategory,
                  );
                },
              );
            },
            itemCount: foodCategoryList.length,
          ),
        ),
      ),
    );
  }
}
