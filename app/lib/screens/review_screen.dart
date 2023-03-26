import 'package:app/common/styles/colors.dart';
import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:app/common/widgets/screen_title.dart';
import 'package:app/services/firebase/analyst.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String reviewValue = 'None';
  List<bool> isSelected = [false, false, false];
  dynamic isValid = 'initialized';

  // Validation
  // check whether client doesn't select any option and try to submit or not
  void validReview() {
    if (isSelected.where((state) => state == true).isEmpty) {
      setState(() {
        isValid = false;
      });
    } else {
      setState(() {
        isValid = true;
      });
      print('Enable submission: $isValid');
      for (final e in isSelected) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ScreenTitle(
            title: '정보가 도움이 됐나요?',
          ),
          const SizedBox(
            height: 60,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToggleButtons(
                selectedBorderColor: Palette.$brown100,
                fillColor: Palette.$brown100.withOpacity(0.7),
                splashColor: Palette.$brown100,
                borderRadius: BorderRadius.circular(4.0),
                isSelected: isSelected,
                onPressed: (index) {
                  // Respond to button selection
                  setState(() {
                    isSelected = [false, false, false];
                    isSelected[index] = !isSelected[index];
                    reviewValue = index == 0
                        ? 'like'
                        : index == 1
                            ? 'neutral'
                            : 'dislike';
                    print(reviewValue);
                    validReview();
                  });
                },
                children: const [
                  ReviewIcon(
                    icon: Icons.thumb_up,
                    text: '좋아요',
                    color: Colors.redAccent,
                  ),
                  ReviewIcon(
                    icon: Icons.chat_bubble,
                    text: '보통',
                    color: Colors.orange,
                  ),
                  ReviewIcon(
                    icon: Icons.thumb_down,
                    text: '싫어요',
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(
              30.0,
            ),
            child: MenuButton(
                text: '리뷰 등록',

                // Submit review to Firebase to collect only if validated
                // Client must select any option
                onPressed: () async {
                  if (isValid == true) {
                    setState(() {
                      isSelected = [false, false, false];
                    });
                    validReview();
                    FirebaseAnalyst.logEvent(
                      eventName: 'review',
                      data: {
                        'value': reviewValue,
                      },
                    );
                    print('Review has been submitted');
                  } else {
                    setState(() {
                      isValid = false;
                    });
                  }
                }),
          ),
          if (isValid != false)
            Container()
          else
            const Text(
              '세 가지 옵션 중 하나를 선택하세요!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class ReviewIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String? text;
  const ReviewIcon({
    super.key,
    required this.icon,
    required this.color,
    this.text,
  });

  @override
  State<ReviewIcon> createState() => _ReviewIconState();
}

class _ReviewIconState extends State<ReviewIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: 70,
            color: widget.color,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ScreenTitle(
              title: widget.text ?? 'None',
            ),
          ),
        ],
      ),
    );
  }
}
