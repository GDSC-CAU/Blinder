import 'package:app/common/widgets/menu_button.dart';
import 'package:app/common/widgets/route_layout.dart';
import 'package:flutter/material.dart';

class ScrollTestPage extends StatelessWidget {
  const ScrollTestPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RouteLayout(
      onPressed: () {
        Navigator.of(context).pop();
      },
      routeText: "클릭해서 뒤로가기",
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
        SizedBox(
          height: 500,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MenuButton(
                    text: '비빔밥 9,000',
                    onPressed: () {},
                  ),
                  MenuButton(
                    text: 'Menu',
                    onPressed: () {},
                  ),
                  MenuButton(
                    text: 'Menu',
                    onPressed: () {},
                  ),
                  MenuButton(
                    text: 'Menu',
                    onPressed: () {},
                  ),
                  MenuButton(
                    text: 'Menu',
                    onPressed: () {},
                  ),
                  MenuButton(
                    text: 'Menu',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
