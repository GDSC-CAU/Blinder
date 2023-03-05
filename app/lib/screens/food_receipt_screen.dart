import 'package:app/common/styles/colors.dart';
import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/bottom_button.dart';
import 'package:app/common/widgets/screen_title.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:app/router/app_router.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodReceiptScreen extends StatelessWidget {
  const FoodReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalPrice = context.read<FoodCartProvider>().getTotalPrice();
    ttsController
        .speak('주문서가 완성됐습니다. 종업원에게 주문서를 보여주세요. 총 가격은 $totalPrice 원 입니다.');

    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Flexible(
            child: ScreenTitle(
              title: '주문서',
            ),
          ),
          Flexible(
            flex: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    columnSpacing: 40,
                    dataRowHeight: 60,
                    headingRowColor: MaterialStateProperty.all(
                      Palette.$brown100,
                    ),
                    dividerThickness: 1,
                    border: const TableBorder(
                      bottom: BorderSide(
                        color: Palette.$brown300,
                        width: 4,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    decoration: const BoxDecoration(
                      color: Palette.$white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          '메뉴',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          '개수',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          '가격',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    rows:
                        context.watch<FoodCartProvider>().getFoodCartItemList(),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ScreenTitle(
              title: '총 가격: $totalPrice 원',
            ),
          ),
          Flexible(
            child: BottomButton(
              text: '돌아가기',
              onPressed: () {
                context.read<FoodCartProvider>().clearFoodCartItems();
                AppRouter.moveAndClear(
                  context,
                  to: RouterPath.mainVoice,
                  clearRouterStackUntil: (route) => false,
                );
              },
              ttsText: '메인 화면으로 돌아갑니다.',
            ),
          ),
        ],
      ),
    );
  }
}
