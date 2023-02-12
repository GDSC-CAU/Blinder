import 'package:flutter/material.dart';

import '../models/item.dart';

class CartProvider with ChangeNotifier {
  final List<Item> items = [
    Item(count: 2, name: "PASTA", price: 12000),
    Item(count: 3, name: "Burger", price: 14000),
  ];

  void addItem(Item newItem) {
    items.add(newItem);
  }

  List<DataRow> getItemList() {
    return items
        .map(
          (item) => DataRow(
            cells: [
              DataCell(Text(item.name)),
              DataCell(Text(item.count.toString())),
              DataCell(Text(item.price.toString())),
            ],
          ),
        )
        .toList();
  }
}
