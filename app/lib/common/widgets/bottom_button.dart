import 'package:app/common/styles/colors.dart';
import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  const BottomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.child,
  });

  final void Function() onPressed;
  final String text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        alignment: Alignment.center,
        backgroundColor: Palette.$brown700,
        splashFactory: NoSplash.splashFactory,
        foregroundColor: Palette.$brown100,
        fixedSize: Size(width, 100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        elevation: 2,
        enableFeedback: true,
      ),
      onPressed: onPressed,
      child: child ??
          Text(
            text,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
    );
  }
}
