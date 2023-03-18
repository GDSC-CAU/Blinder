import 'dart:io';

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
  static const _initialParse =
      "총 6개의 음식 메뉴가 가로 2줄, 세로 3줄, 창문형으로 배치되어있습니다. 하단에는 페이지를 이동할 수 있는 버튼, 2개가 있습니다. 하단의 버튼들을 눌러서 메뉴를 살펴보세요!";

  bool _isFirstAccess = true;

  static const _initialPageCount = 1;
  int _currentPageCount = _initialPageCount;

  int? _maximumCount;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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

    final menuButtonHeight = MediaQuery.of(context).size.width / 2;
    const totalGridGap = 5;
    final screenHeight = Platform.isAndroid
        ? AppBar().preferredSize.height
        : AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    final gridMargin = Platform.isAndroid ? totalGridGap * 4 : 0;
    final bottomButtonHeight =
        (MediaQuery.of(context).size.height - screenHeight) -
            3 * menuButtonHeight -
            gridMargin;

    final isFirst = _currentPageCount == 1;
    final isLast = _currentPageCount == _maximumCount;

    final menuOverallText =
        "$_currentPageCount페이지 메뉴는 다음과 같습니다. ${currentPageFoodMenuList.map((e) => e.name).join(", ")}";
    final String text =
        _isFirstAccess ? "$_initialParse, $menuOverallText" : menuOverallText;

    return FutureBuilder(
      future: ttsController.speak(text),
      builder: (context, snapshot) => AppScaffold(
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: GridView.count(
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  crossAxisCount: 2,
                  clipBehavior: Clip.antiAlias,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final foodMenu in currentPageFoodMenuList)
                      InfoContainer(
                        backgroundColor: Palette.$brown100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              foodMenu.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              foodMenu.price,
                              style: const TextStyle(
                                fontSize: 20,
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
            SizedBox(
              height: bottomButtonHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(
                    text: isFirst ? "첫번째 메뉴페이지" : "이전",
                    onPressed: () async {
                      if (isFirst) {
                        setState(() {
                          _isFirstAccess = false;
                        });
                      }
                      _decreasePageCount();
                      await ttsController.speak(
                        "${isFirst ? "첫번째" : _currentPageCount} 페이지 입니다.",
                      );
                    },
                    backgroundColor: Colors.red.shade500,
                    foregroundColor: Palette.$white,
                  ),
                  Button(
                    text: isLast ? "마지막 메뉴페이지" : "다음",
                    onPressed: () async {
                      if (isFirst) {
                        setState(() {
                          _isFirstAccess = false;
                        });
                      }
                      _increasePageCount();
                      await ttsController.speak(
                          "${isLast ? "마지막, $_currentPageCount" : _currentPageCount} 페이지입니다.");
                    },
                    backgroundColor: Colors.green.shade500,
                    foregroundColor: Palette.$white,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  final String text;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final void Function()? onPressed;

  const Button({
    super.key,
    required this.text,
    this.onPressed,
    this.child,
    this.backgroundColor = Palette.$brown700,
    this.foregroundColor = Palette.$brown100,
  });

  @override
  Widget build(BuildContext context) {
    final halfOfScreenSize = MediaQuery.of(context).size.width / 2;
    return ElevatedButton(
      onPressed: () async {
        if (onPressed != null) onPressed!();
      },
      style: ElevatedButton.styleFrom(
        enableFeedback: true,
        alignment: Alignment.center,
        shape: const BeveledRectangleBorder(),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        splashFactory: NoSplash.splashFactory,
        fixedSize: Size(halfOfScreenSize, halfOfScreenSize),
      ),
      child: child ??
          Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
    );
  }
}

class InfoContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const InfoContainer({
    super.key,
    required this.child,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final halfOfScreenSize = MediaQuery.of(context).size.width / 2;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.zero),
        color: backgroundColor,
        border: backgroundColor != null
            ? Border.all(
                color: backgroundColor!,
                width: 2,
              )
            : null,
      ),
      width: halfOfScreenSize,
      child: child,
    );
  }
}
