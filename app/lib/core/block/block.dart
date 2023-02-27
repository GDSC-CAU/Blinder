import 'dart:math';

import 'package:flutter/material.dart';

class Coord extends Point<num> {
  Coord({
    required num x,
    required num y,
  }) : super(x, y);

  factory Coord.translate(
    Coord targetCoord, {
    required num xAmount,
    required num yAmount,
  }) =>
      Coord(
        x: targetCoord.x + xAmount,
        y: targetCoord.y + yAmount,
      );

  @override
  String toString() {
    return "{\n       x: $x,\n       y: $y\n     }";
  }
}

class RectPosition {
  Coord tl, tr, br, bl;
  RectPosition({
    required this.tl,
    required this.tr,
    required this.br,
    required this.bl,
  });

  factory RectPosition.fromBox(
    Coord centerCoord, {
    required int width,
    required int height,
  }) =>
      RectPosition(
        tl: Coord.translate(
          centerCoord,
          xAmount: -width ~/ 2,
          yAmount: height ~/ 2,
        ),
        tr: Coord.translate(
          centerCoord,
          xAmount: width ~/ 2,
          yAmount: height ~/ 2,
        ),
        br: Coord.translate(
          centerCoord,
          xAmount: width ~/ 2,
          yAmount: -height ~/ 2,
        ),
        bl: Coord.translate(
          centerCoord,
          xAmount: -width ~/ 2,
          yAmount: -height ~/ 2,
        ),
      );
}

class Block {
  final RectPosition initialPosition;

  Rect get boundingBox => Rect.fromLTRB(
        position.tl.x.toDouble(),
        position.tl.y.toDouble(),
        position.br.x.toDouble(),
        position.br.y.toDouble(),
      );

  int get width => (position.tr.x - position.tl.x).abs().toInt();
  int get height => (position.tr.y - position.br.y).abs().toInt();

  Coord get tl => position.tl;
  Coord get tr => position.tr;
  Coord get br => position.br;
  Coord get bl => position.bl;
  Coord get center => Coord(
        x: (tl.x + tr.x) ~/ 2,
        y: (tl.y + bl.y) ~/ 2,
      );

  final RectPosition position;

  Block({
    required this.initialPosition,
  }) : position = mean(
          RectPosition(
            tl: initialPosition.tl,
            tr: initialPosition.tr,
            br: initialPosition.br,
            bl: initialPosition.bl,
          ),
        );

  static RectPosition mean(RectPosition targetPosition) {
    final meanPosition = RectPosition(
      tl: Coord(
        x: (targetPosition.tl.x + targetPosition.bl.x) ~/ 2,
        y: (targetPosition.tl.y + targetPosition.tr.y) ~/ 2,
      ),
      tr: Coord(
        x: (targetPosition.tr.x + targetPosition.br.x) ~/ 2,
        y: (targetPosition.tl.y + targetPosition.tr.y) ~/ 2,
      ),
      br: Coord(
        x: (targetPosition.tr.x + targetPosition.br.x) ~/ 2,
        y: (targetPosition.bl.y + targetPosition.br.y) ~/ 2,
      ),
      bl: Coord(
        x: (targetPosition.tl.x + targetPosition.bl.x) ~/ 2,
        y: (targetPosition.bl.y + targetPosition.br.y) ~/ 2,
      ),
    );

    return meanPosition;
  }

  @override
  String toString() {
    return "{\n     tl: $tl,\n     width: $width,\n     height: $height,\n   }\n";
  }
}
