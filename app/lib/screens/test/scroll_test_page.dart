import 'package:app/common/widgets/menu_button.dart';
import 'package:app/common/widgets/screen_layout.dart';
import 'package:app/providers/food_map_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ScrollTestPage extends StatelessWidget {
  const ScrollTestPage({
    super.key,
  });

  String formatMoney(
    num amount, {
    String locale = "ko_KR",
  }) {
    final formatter = NumberFormat.simpleCurrency(
      locale: locale,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<FoodMapProvider>();
    final categories = controller.getFoodCategory();
    final menus = controller.getFoodMenuByCategory(categories[0]);

    return ScreenLayout(
      onPressed: () {
        Navigator.of(context).pop();
      },
      routeText: "클릭해서 뒤로가기",
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Try Scroll',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 500,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemBuilder: (context, index) {
                final menu = menus[index];
                return MenuButton(
                  text: "${menu.name} ${menu.price}",
                  onPressed: () {},
                );
              },
              itemCount: menus.length,
            ),
          ),
        ),
      ],
    );
  }
}
