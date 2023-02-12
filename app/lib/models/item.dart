class Item {
  String name;
  num price;
  num count;

  Item({required this.name, required this.price, required this.count});

  @override
  String toString() => "\n    { name: $name, price: $price, count: $count }";
}
