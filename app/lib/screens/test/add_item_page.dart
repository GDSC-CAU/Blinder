import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/models/food_cart_item.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddItemPage extends StatelessWidget {
  const AddItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: ElevatedButton(
        onPressed: () {
          context.read<FoodCartProvider>().addItem(
                FoodCartItem(
                  name: "FRIES",
                  price: 5000,
                  count: 2,
                ),
              );
        },
        child: const Text('Add Item'),
      ),
    );
  }
}
