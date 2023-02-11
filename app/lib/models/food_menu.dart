import 'package:app/models/model_factory.dart';

class FoodMenu implements Model<FoodMenu> {
  String name = "";
  num price = 0;

  @override
  void set(JsonMap jsonMap) {
    name = jsonMap["name"] as String;
    price = int.parse(jsonMap["price"] as String);
  }

  @override
  FoodMenu create() => FoodMenu();

  @override
  String toString() => "\n    { name: $name, price: $price }";
}
