class FoodCartItem {
  String name;
  num price, count;

  FoodCartItem({
    required this.name,
    required this.price,
    required this.count,
  });

  @override
  String toString() => "\n    { name: $name, price: $price, count: $count }";
}
