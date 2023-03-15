import 'dart:ui';
import 'dart:ui' as ui;

import 'package:app/ml/coordinates_translator.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class ObjectDetectorPainter extends CustomPainter {
  final List<DetectedObject> detectedObjectList;
  final Size absoluteSize;
  final InputImageRotation rotation;
  final Color _color;
  final double _strokeWidth;

  ObjectDetectorPainter({
    required this.detectedObjectList,
    required this.rotation,
    required this.absoluteSize,
    required Color color,
    required double strokeWidth,
  })  : _color = color,
        _strokeWidth = strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..color = _color;

    final Paint background = Paint()..color = const Color(0x99000000);

    for (final DetectedObject detectedObject in detectedObjectList) {
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 16,
          textDirection: TextDirection.ltr,
        ),
      );
      builder.pushStyle(
        ui.TextStyle(
          color: Colors.lightGreenAccent,
          background: background,
        ),
      );

      for (final Label label in detectedObject.labels) {
        builder.addText('${label.text} ${label.confidence}\n');
      }

      builder.pop();

      final left = CoordTranslator.translateX(
        detectedObject.boundingBox.left,
        rotation,
        size,
        absoluteSize,
      );
      final top = CoordTranslator.translateY(
        detectedObject.boundingBox.top,
        rotation,
        size,
        absoluteSize,
      );
      final right = CoordTranslator.translateX(
        detectedObject.boundingBox.right,
        rotation,
        size,
        absoluteSize,
      );
      final bottom = CoordTranslator.translateY(
        detectedObject.boundingBox.bottom,
        rotation,
        size,
        absoluteSize,
      );

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );

      canvas.drawParagraph(
        builder.build()
          ..layout(
            ParagraphConstraints(
              width: right - left,
            ),
          ),
        Offset(left, top),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
