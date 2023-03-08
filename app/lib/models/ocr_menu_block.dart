import 'package:app/models/model_factory.dart';

typedef Vertices = List<List<int>>;

class OcrMenuBlock implements Model<OcrMenuBlock> {
  Vertices vertices = [];
  String text = "";

  @override
  void set(jsonMap) {
    vertices = jsonMap["vertices"] as Vertices;
    text = jsonMap["text"] as String;
  }

  @override
  JsonMap toJson() => {
        "text": text,
        "vertices": vertices,
      };

  @override
  OcrMenuBlock create() => OcrMenuBlock();
}
