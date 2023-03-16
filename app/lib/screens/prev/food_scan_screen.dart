import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:app/core/menu_engine.dart';
import 'package:app/models/food_menu.dart';
import 'package:app/providers/food_menu_provider.dart';
import 'package:app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen({super.key});

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

enum Status {
  failed,
  loading,
  success,
  wait,
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  Status status = Status.wait;
  String? menu;

  final menuEngine = MenuEngine();

  List<FoodMenu> foodMenuList = [];

  Future<void> _getFoodMenu() async {
    final pickedImage = await ImagePicker.platform.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      status = Status.loading;
    });

    if (pickedImage == null) {
      return;
    }

    await menuEngine.parse(pickedImage.path);

    print("===============================================================");
    print("이미지 경로: ${pickedImage.path}");
    print("받은 block 갯수: ${menuEngine.menuBlockList.length}\n");

    setState(() {
      status = Status.success;
      foodMenuList = menuEngine.foodMenu;
      menu = foodMenuList.fold(
        "",
        (previousValue, element) =>
            "$previousValue\n ${element.name}: ${element.price}",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FoodMenuProvider>();

    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              text: '이미지 고르기',
              onPressed: _getFoodMenu,
            ),
            if (status == Status.success)
              MenuButton(
                text: "메뉴 고르러 가기",
                onPressed: () {
                  controller.updateFoodMenu(foodMenuList);

                  AppRouter.move(
                    context,
                    to: RouterPath.foodMenuBoard,
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                status == Status.success ? "실행 성공\n$menu" : "로딩중",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                locale: const Locale('kr'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
