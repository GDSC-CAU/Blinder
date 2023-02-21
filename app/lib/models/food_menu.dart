import 'package:app/models/model_factory.dart';

class FoodMenu implements Model<FoodMenu> {
  String name = "";
  num price = 0;

  @override
  void set(JsonMap jsonMap) {
    name = jsonMap["name"] as String;
    price = num.tryParse(jsonMap["price"] as String) ?? 0;
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
