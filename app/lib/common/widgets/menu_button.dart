import 'package:app/common/styles/colors.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  static double menuButtonHeight = 70;

  final String text;
  final String? ttsText;
  final void Function() onPressed;
  final Widget? child;

  const MenuButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.ttsText,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: ElevatedButton(
        onPressed: () {
          if (ttsText != null) ttsController.speak(ttsText!);
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          alignment: Alignment.center,
          elevation: 2,
          backgroundColor: Palette.$brown700,
          splashFactory: NoSplash.splashFactory,
          foregroundColor: Palette.$brown100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          fixedSize: Size(width, menuButtonHeight),
          enableFeedback: true,
        ),
        child: SingleChildScrollView(
          child: child ??
              Text(
                text,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
        ),
      ),
    );
  }
}
