import 'package:app/common/styles/colors.dart';
import 'package:app/common/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class CartTestPage extends StatelessWidget {
  CartTestPage({super.key});

  final List<DataRow> data = [
    {"menu": "PASTA", "count": 1, "price": 14000},
    {"menu": "BURGER", "count": 2, "price": 13000},
    {"menu": "STEAK", "count": 1, "price": 50000},
    {"menu": "FRIES", "count": 1, "price": 3500},
    {"menu": "CHICKEN", "count": 2, "price": 20000},
    {"menu": "COKE", "count": 1, "price": 3000},
  ]
      .map((item) => DataRow(cells: [
            DataCell(Text(item["menu"]! as String)),
            DataCell(Text(item["count"]!.toString())),
            DataCell(Text(item["price"]!.toString())),
          ]))
      .toList();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: DataTable(
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
        rows: data,
      ),
    );
  }
}
