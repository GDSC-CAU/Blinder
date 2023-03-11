import 'package:flutter/services.dart';

enum State { create, ready, execute }

class Detector {
  static const platform = MethodChannel('detectMenu');
  State state = State.create;

  Detector();
}
