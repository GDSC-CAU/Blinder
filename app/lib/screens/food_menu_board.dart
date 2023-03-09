import 'package:app/common/styles/colors.dart';
import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/providers/food_menu_provider.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodMenuBoard extends StatefulWidget {
  const FoodMenuBoard({super.key});

  @override
  State<FoodMenuBoard> createState() => _FoodMenuBoardState();
}

class _FoodMenuBoardState extends State<FoodMenuBoard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _currentPageCount = 1;
  int? _maximumCount;

  void _decreasePageCount() => setState(() {
        if (_currentPageCount == 1) return;
        _currentPageCount -= 1;
      });

  void _increasePageCount() => setState(() {
        if (_currentPageCount == _maximumCount) {
          return;
        }
        _currentPageCount += 1;
      });

  void _setPageMaximumCount({
    required int totalItemCount,
    required int displayCount,
  }) =>
      setState(() {
        if (totalItemCount ~/ displayCount == 0 ||
            totalItemCount % displayCount == 0) {
          _maximumCount = totalItemCount ~/ displayCount;
          return;
        }
        _maximumCount = totalItemCount ~/ displayCount + 1;
      });

  T _getPaginatedItem<T extends List>({
    required T items,
    required int currentPageCount,
    required int displayCount,
  }) {
    final startCount = (currentPageCount - 1) * displayCount;
    final endCount = currentPageCount * displayCount;

    final itemLength = items.length;

    final isOver = startCount > itemLength;
    if (isOver) return items;

    return items.sublist(
      startCount,
      endCount <= itemLength ? endCount : null,
    ) as T;
  }

  @override
  Widget build(BuildContext context) {
    const menuCountPerPage = 6;
    final currentFoodMenu = Provider.of<FoodMenuProvider>(
      context,
    ).foodMenuList;

    final currentPageFoodMenuList = _getPaginatedItem(
      items: currentFoodMenu,
      currentPageCount: _currentPageCount,
      displayCount: menuCountPerPage,
    );

    _setPageMaximumCount(
      displayCount: menuCountPerPage,
      totalItemCount: currentFoodMenu.length,
    );

    return AppScaffold(
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: GridView.count(
                childAspectRatio: 1 / .975,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                crossAxisCount: 2,
                clipBehavior: Clip.antiAlias,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final foodMenu in currentPageFoodMenuList)
                    Button(
                      text: "",
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            foodMenu.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            foodMenu.price,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Button(
                text: _currentPageCount == 1 ? "첫번째 메뉴페이지" : "이전",
                onPressed: _decreasePageCount,
                backgroundColor: Colors.red.shade500,
                foregroundColor: Palette.$white,
              ),
              Button(
                text: _currentPageCount == _maximumCount ? "마지막 메뉴페이지" : "다음",
                onPressed: _increasePageCount,
                backgroundColor: Colors.green.shade500,
                foregroundColor: Palette.$white,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class Button extends StatelessWidget {
  final String text;
  final String? ttsText;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final void Function()? onPressed;

  const Button({
    super.key,
    required this.text,
    this.onPressed,
    this.ttsText,
    this.child,
    this.backgroundColor = Palette.$brown700,
    this.foregroundColor = Palette.$brown100,
  });

  @override
  Widget build(BuildContext context) {
    final halfOfScreenSize = MediaQuery.of(context).size.width / 2;
    return ElevatedButton(
      onPressed: () {
        if (ttsText != null) ttsController.speak(ttsText!);
        if (onPressed != null) onPressed!();
      },
      style: ElevatedButton.styleFrom(
        alignment: Alignment.center,
        backgroundColor: backgroundColor,
        splashFactory: NoSplash.splashFactory,
        foregroundColor: foregroundColor,
        enableFeedback: true,
        maximumSize: Size(halfOfScreenSize, 200),
        fixedSize: Size(halfOfScreenSize, 200),
        shape: const BeveledRectangleBorder(),
      ),
      child: child ??
          Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
    );
  }
}
