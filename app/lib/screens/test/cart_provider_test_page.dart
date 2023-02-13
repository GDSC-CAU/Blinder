import 'package:app/common/styles/colors.dart';
import 'package:app/common/widgets/app_scaffold.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:app/screens/test/add_item_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartTestPage extends StatelessWidget {
  const CartTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DataTable(
            columnSpacing: 70,
            decoration: BoxDecoration(
              color: Palette.$brown100,
              borderRadius: BorderRadius.circular(20),
            ),
            columns: const [
              DataColumn(
                label: Text(
                  'Name',
                ),
              ),
              DataColumn(
                label: Text(
                  'Count',
                ),
              ),
              DataColumn(
                label: Text(
                  'Price',
                ),
              ),
            ],
            rows: context.watch<FoodCartProvider>().getFoodCartItemList(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddItemPage()),
              );
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
