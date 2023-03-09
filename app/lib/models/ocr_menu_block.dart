// ignore_for_file: constant_identifier_names

import 'package:app/core/block/block.dart';
import 'package:app/models/model_factory.dart';

typedef Vertices = List<List<int>>;

const X = 0;
const Y = 1;
const TL = 0;
const TR = 1;
const BR = 2;
const BL = 3;

class OcrMenuBlock implements Model<OcrMenuBlock> {
  Vertices vertices = [];
  String text = "";
  Coord get tl => Coord(x: vertices[TL][X], y: vertices[TL][Y]);
  Coord get tr => Coord(x: vertices[TR][X], y: vertices[TR][Y]);
  Coord get br => Coord(x: vertices[BR][X], y: vertices[BR][Y]);
  Coord get bl => Coord(x: vertices[BL][X], y: vertices[BL][Y]);

  Vertices _transformToVertices(List<dynamic> jsonVertices) =>
      jsonVertices.fold<Vertices>(
        [],
        (
          accVertices,
          jsonCoordList,
        ) {
          if (jsonCoordList is List) {
            final transformedCoordList = jsonCoordList.fold<List<int>>(
                [],
                (accCoordList, jsonCoord) => [
                      ...accCoordList,
                      jsonCoord as int,
                    ]);
            accVertices.add(transformedCoordList);
          } else {
            print(
                "type of element is ${jsonCoordList.runtimeType}, $jsonCoordList");
          }
          return accVertices;
        },
      );

  @override
  void set(jsonMap) {
    final jsonVertices = jsonMap["vertices"] as List<dynamic>;
    vertices = _transformToVertices(jsonVertices);
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
