import 'package:flutter/material.dart';

import '../models/item.dart';

class CartProvider with ChangeNotifier {
  final List<Item> items = [];

  void addItem(Item newItem) {
    items.add(newItem);
    notifyListeners();
  }

  void printItems() {
    items.map((item) => item.toString()).forEach(print);
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
