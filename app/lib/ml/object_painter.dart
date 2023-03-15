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

    for (final DetectedObject detectedObject in detectedObjectList) {
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
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
