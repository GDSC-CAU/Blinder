import 'package:app/common/widgets/screen_layout.dart';
import 'package:app/models/model_factory.dart';
import 'package:app/providers/food_map_provider.dart';
import 'package:app/screens/test/add_item_page.dart';
import 'package:app/screens/test/scroll_test_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'menu_button_test_page.dart';

class MainTestPage extends StatelessWidget {
  Future<List<JsonMap>> fetchJson() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );
    final exampleFMJsonResponse = [
      {
        "category": "pasta",
        "menu": [
          {"name": "멜팅 스테이크 파스타", "price": "17000"},
          {"name": "미트소스 파스타", "price": "15000"},
          {"name": "상하이 파스타", "price": "17500"},
          {"name": "까르보라나 파스타", "price": "15000"},
          {"name": "봉골레 파스타", "price": "17000"},
        ]
      },
      {
        "category": "salad",
        "menu": [
          {"name": "채식 샐러드", "price": "7000"},
          {"name": "닭가슴살 샐러드", "price": "8000"}
        ]
      }
    ];
    return Future(
      () => exampleFMJsonResponse,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenLayout(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ScrollTestPage(),
          ),
        );
      },
      routeText: "스크롤 테스트로 이동",
      children: [
        FutureBuilder(
            future: fetchJson(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final controller = Provider.of<FoodMapProvider>(context);
                controller.updateFoodMapFromJson(snapshot.data!);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MenuButtonTestPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Custom Button with ${controller.foodMap.dataList[0].category}',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ScrollTestPage(),
                            ),
                          );
                        },
                        child: const Text('Scroll Button'),
                      ),
                    ),
                  ],
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MenuButtonTestPage(),
                    ),
                  );
                },
                child: const Text('Custom Button'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ScrollTestPage(),
                    ),
                  );
                },
                child: const Text('Scroll Button'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddItemPage(),
                    ),
                  );
                },
                child: const Text('Add Item'),
              ),
            ),
          ],
        )
      ],
    );
  }
}
