import 'package:app/models/model_factory.dart';

class FoodMenu implements Model<FoodMenu> {
  String name = "", price = "";

  @override
  void set(JsonMap jsonMap) {
    name = jsonMap["name"] as String;
    price = jsonMap["price"] as String;
  }

  @override
  JsonMap toJson() => {
        "name": name,
        "price": price,
      };

  @override
  FoodMenu create() => FoodMenu();

  @override
  String toString() => "\n    { name: $name, price: $price }";
}
