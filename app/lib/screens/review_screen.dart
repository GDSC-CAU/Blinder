import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/common/widgets/menu_button.dart';
import 'package:app/common/widgets/screen_title.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String review = 'None';
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ReviewIconButton(
                  icon: Icons.thumb_up,
                  onPressed: () => {},
                  color: Colors.redAccent,
                  text: '좋아요',
                ),
                ReviewIconButton(
                  icon: Icons.chat_bubble,
                  onPressed: () => {},
                  color: Colors.orange,
                  text: '보통',
                ),
                ReviewIconButton(
                  icon: Icons.thumb_down,
                  onPressed: () => {},
                  color: Colors.blueGrey,
                  text: '싫어요',
                ),
              ],
            ),
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
              onPressed: () => {},
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final String? text;
  const ReviewIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 80,
          icon: Icon(
            icon,
          ),
          onPressed: onPressed,
          color: color,
        ),
        ScreenTitle(
          title: text ?? 'None',
        ),
      ],
    );
  }
}
