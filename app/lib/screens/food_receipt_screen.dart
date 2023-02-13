import 'package:app/common/styles/colors.dart';
import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/bottom_button.dart';
import 'package:app/common/widgets/screen_title.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodReceiptScreen extends StatelessWidget {
  const FoodReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ScreenTitle(
                  title: '주문서',
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    columnSpacing: 70,
                    decoration: BoxDecoration(
                      color: Palette.$brown100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Name',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Count',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Price',
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
            child: Align(
              alignment: Alignment.bottomCenter,
              child: BottomButton(
                text: '돌아가기',
                onPressed: () {
                  context.read<FoodCartProvider>().clearItems();
                  AppRouter.moveAndClear(context,
                      to: RouterPath.mainVoice,
                      clearRouterStackUntil: (route) => false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
