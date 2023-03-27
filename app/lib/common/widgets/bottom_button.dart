import 'package:app/common/styles/colors.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  static double bottomButtonHeight = 75;

  final void Function() onPressed;
  final String text;
  final String? ttsText;

  const BottomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.ttsText,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: () {
        if (ttsText != null) tts.speak(ttsText!);
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        alignment: Alignment.center,
        backgroundColor: Palette.$brown700,
        splashFactory: NoSplash.splashFactory,
        foregroundColor: Palette.$brown100,
        fixedSize: Size(width, bottomButtonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        elevation: 2,
        enableFeedback: true,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
