import 'package:app/common/styles/colors.dart';
import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.center,
          elevation: 2,
          backgroundColor: Palette.$brown700,
          splashFactory: NoSplash.splashFactory,
          foregroundColor: Palette.$brown100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          fixedSize: Size(width, 150),
          enableFeedback: true,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

const a = 3;
