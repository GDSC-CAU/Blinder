import 'package:app/commons/widgets/default_scaffold.dart';
import 'package:flutter/material.dart';

import '../../commons/widgets/menu_button.dart';

class ScrollTestPage extends StatelessWidget {
  const ScrollTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Try Scroll',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(20),
              ),
              height: 500,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      MenuButton(
                        buttonName: 'Menu',
                      ),
                      MenuButton(
                        buttonName: 'Menu',
                      ),
                      MenuButton(
                        buttonName: 'Menu',
                      ),
                      MenuButton(
                        buttonName: 'Menu',
                      ),
                      MenuButton(
                        buttonName: 'Menu',
                      ),
                      MenuButton(
                        buttonName: 'Menu',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
