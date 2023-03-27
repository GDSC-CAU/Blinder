import 'package:app/common/styles/colors.dart';
import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/screen_title.dart';
import 'package:app/router/app_router.dart';
import 'package:app/services/firebase/analyst.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

enum ReviewGrade {
  like,
  neutral,
  dislike,
}

class _ReviewScreenState extends State<ReviewScreen> {
  ReviewGrade? reviewGrade;
  List<bool> reviewSelectedState = [false, false, false];

  Future<void> submitReview() async {
    const eventName = "review";
    const eventDataKey = "grade";

    await FirebaseAnalyst.logEvent(
      eventName: eventName,
      data: {
        eventDataKey: reviewGrade.toString(),
      },
    );

    print('Review has been submitted: ${reviewGrade.toString()}');

    AppRouter.back(context);
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
                direction: Axis.vertical,
                selectedBorderColor: Palette.$brown100,
                fillColor: Palette.$brown100.withOpacity(0.7),
                splashColor: Palette.$brown100,
                borderRadius: BorderRadius.circular(4.0),
                isSelected: reviewSelectedState,
                onPressed: (pressedButtonIndex) async {
                  // Respond to button selection
                  setState(() {
                    switch (pressedButtonIndex) {
                      case 0:
                        reviewGrade = ReviewGrade.like;
                        return;
                      case 1:
                        reviewGrade = ReviewGrade.neutral;
                        return;
                      case 2:
                        reviewGrade = ReviewGrade.dislike;
                        return;
                      default:
                        return;
                    }
                  });
                  await submitReview();
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
            size: 120,
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
