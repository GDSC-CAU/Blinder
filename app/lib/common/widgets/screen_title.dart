import 'package:app/common/styles/colors.dart';
import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  final String title;

  const ScreenTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 25,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Palette.$brown900,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
