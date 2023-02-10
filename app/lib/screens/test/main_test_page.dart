import 'package:app/commons/widgets/default_scaffold.dart';
import 'package:app/screens/test/scroll_test_page.dart';
import 'package:flutter/material.dart';

import 'menu_button_test_page.dart';

class MainTestPage extends StatelessWidget {
  const MainTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const MenuButtonTestPage()));
                },
                child: const Text('Custom Button')),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ScrollTestPage()));
                },
                child: const Text('Scroll Button')),
          ),
        ],
      ),
    );
  }
}
