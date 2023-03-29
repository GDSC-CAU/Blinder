import 'package:app/common/styles/colors.dart';
import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/screen_title.dart';
import 'package:app/router/app_router.dart';
import 'package:app/services/firebase/analyst.dart';
import 'package:app/utils/tts.dart';
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
  @override
  void initState() {
    super.initState();
    tts.speak('어플에 얼마나 만족했는지 평가 부탁드립니다.');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Flexible(
            child: ScreenTitle(
              title: '정보가 도움이 됐나요?',
            ),
          ),
          Flexible(
            flex: 2,
            child: ReviewIconButton(
              icon: Icons.thumb_up,
              color: Colors.redAccent,
              text: '좋아요',
              grade: ReviewGrade.like,
            ),
          ),
          Flexible(
            flex: 2,
            child: ReviewIconButton(
              icon: Icons.chat_bubble,
              color: Colors.orange,
              text: '보통이에요',
              grade: ReviewGrade.neutral,
            ),
          ),
          Flexible(
            flex: 2,
            child: ReviewIconButton(
              icon: Icons.thumb_down,
              color: Colors.blueGrey,
              text: '별로에요',
              grade: ReviewGrade.dislike,
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String? text;
  final ReviewGrade grade;
  const ReviewIconButton({
    super.key,
    required this.icon,
    required this.color,
    this.text,
    required this.grade,
  });

  @override
  State<ReviewIconButton> createState() => _ReviewIconButtonState();
}

class _ReviewIconButtonState extends State<ReviewIconButton> {
  final Map<ReviewGrade, String> reviewProperties = {
    ReviewGrade.like: 'like',
    ReviewGrade.neutral: 'neutral',
    ReviewGrade.dislike: 'dislike'
  };

  Future<void> submitReview(ReviewGrade grade) async {
    const propertyName = "review";

    await FirebaseAnalyst.setUserProperty(
      propertyName: propertyName,
      value: reviewProperties[grade],
    );

    print('Review has been submitted: ${grade.toString()}');

    AppRouter.back(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        radius: 100,
        backgroundColor: Palette.$brown100,
        child: IconButton(
          iconSize: 200,
          onPressed: () async {
            await submitReview(widget.grade);
          },
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 100,
                color: widget.color,
              ),
              ScreenTitle(
                title: widget.text ?? 'None',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
