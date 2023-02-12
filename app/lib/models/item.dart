import 'model_factory.dart';

class Item {
  String name;
  num price;
  num count;

  Item({required this.name, required this.price, required this.count});

  JsonMap toJson() => {
        "name": name,
        "price": price,
        "count": count,
      };

  @override
  String toString() => "\n    { name: $name, price: $price, count: $count }";
}
