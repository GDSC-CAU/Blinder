import 'package:app/providers/food_map_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Providers extends StatelessWidget {
  final Widget child;

  const Providers({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FoodMapProvider>(
          create: (_) => FoodMapProvider(),
        )
      ],
      child: child,
    );
  }
}
