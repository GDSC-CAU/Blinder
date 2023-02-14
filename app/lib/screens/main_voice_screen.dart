import 'package:app/common/widgets/screen_layout.dart';
import 'package:app/providers/food_map_provider.dart';
import 'package:app/router/app_router.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void testMockupDataSetup(BuildContext context) {
  context.read<FoodMapProvider>().updateFoodMapFromJson(
    [
      {
        "category": "파스타",
        "menu": [
          {"name": "멜팅 스테이크 파스타", "price": "17000"},
          {"name": "미트소스 파스타", "price": "15000"},
          {"name": "까르보라나 파스타", "price": "15000"},
          {"name": "봉골레 파스타", "price": "14000"},
          {"name": "상하이 해물 파스타", "price": "14000"},
          {"name": "스테이크 칠리 파스타", "price": "17000"},
          {"name": "미트볼 파에냐 파스타", "price": "15000"},
          {"name": "라르로리오 파스타", "price": "15000"},
          {"name": "쉬림프 댄싱 파스타", "price": "14000"},
          {"name": "치즈 미팅 파스타", "price": "14000"},
        ]
      },
      {
        "category": "샐러드",
        "menu": [
          {"name": "채식 샐러드", "price": "7000"},
          {"name": "닭가슴살 샐러드", "price": "8000"},
          {"name": "오리엔탈 치킨 샐러드", "price": "8000"},
          {"name": "레몬 프레쉬 샐러드", "price": "8000"},
        ]
      },
      {
        "category": "피자",
        "menu": [
          {"name": "고르곤졸라 피자", "price": "13000"},
          {"name": "마르게리타 피자", "price": "13000"},
          {"name": "상하이 치킨 피자", "price": "14000"},
          {"name": "머쉬룸 쉬림프 스파이시 피자", "price": "16000"},
        ]
      },
      {
        "category": "세트",
        "menu": [
          {"name": "세트 A", "price": "25000"},
          {"name": "세트 B", "price": "38000"},
          {"name": "세트 C", "price": "48000"},
          {"name": "세트 D", "price": "58000"},
        ]
      },
      {
        "category": "세트2",
        "menu": [
          {"name": "세트 A2", "price": "25000"},
          {"name": "세트 B2", "price": "38000"},
          {"name": "세트 C2", "price": "48000"},
          {"name": "세트 D2", "price": "58000"},
        ]
      },
      {
        "category": "세트3",
        "menu": [
          {"name": "세트 A3", "price": "25000"},
          {"name": "세트 B3", "price": "38000"},
          {"name": "세트 C3", "price": "48000"},
          {"name": "세트 D3", "price": "58000"},
        ]
      },
      {
        "category": "세트4",
        "menu": [
          {"name": "세트 A4", "price": "25000"},
          {"name": "세트 B4", "price": "38000"},
          {"name": "세트 C4", "price": "48000"},
          {"name": "세트 D4", "price": "58000"},
        ]
      }
    ],
  );
}

class MainVoiceScreen extends StatelessWidget {
  const MainVoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    testMockupDataSetup(context);
    ttsController.speak('음식점 이름을 말하거나, 하단의 메뉴판 촬영 버튼을 눌러주세요.');
    return ScreenLayout(
      onPressed: () {
        AppRouter.move(
          context,
          to: RouterPath.foodMenuScan,
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
                  semanticLabel: "음성 인식 버튼",
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
