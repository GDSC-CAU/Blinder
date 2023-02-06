import 'package:flutter/material.dart';

import '../styles/colors.dart';

class DefaultScaffold extends StatelessWidget {
  const DefaultScaffold({super.key, required this.body});
  final Widget body;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appBarColor,
      ),
      body: SafeArea(child: Center(child: body)),
    );
  }
}
