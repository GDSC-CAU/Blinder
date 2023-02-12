import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/item.dart';

class AddItemPage extends StatelessWidget {
  const AddItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: ElevatedButton(
        onPressed: () {
          context.read<CartProvider>().addItem(Item(
                name: "FRIES",
                price: 5000,
                count: 2,
              ));
          context.read<CartProvider>().printItems();
        },
        child: const Text('Add Item'),
      ),
    );
  }
}
