import 'package:app/ml/coordinates_translator.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class ObjectDetectorPainter extends CustomPainter {
  final Color _color;
  final Size _absoluteSize;
  final double _strokeWidth;
  final InputImageRotation _rotation;
  final List<DetectedObject> _detectedObjectList;

  ObjectDetectorPainter({
    required List<DetectedObject> detectedObjectList,
    required InputImageRotation rotation,
    required Size absoluteSize,
    required Color color,
    required double strokeWidth,
  })  : _rotation = rotation,
        _absoluteSize = absoluteSize,
        _detectedObjectList = detectedObjectList,
        _color = color,
        _strokeWidth = strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..color = _color;

    for (final DetectedObject detectedObject in _detectedObjectList) {
      final left = CoordTranslator.translateX(
        detectedObject.boundingBox.left,
        _rotation,
        size,
        _absoluteSize,
      );
      final top = CoordTranslator.translateY(
        detectedObject.boundingBox.top,
        _rotation,
        size,
        _absoluteSize,
      );
      final right = CoordTranslator.translateX(
        detectedObject.boundingBox.right,
        _rotation,
        size,
        _absoluteSize,
      );
      final bottom = CoordTranslator.translateY(
        detectedObject.boundingBox.bottom,
        _rotation,
        size,
        _absoluteSize,
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
