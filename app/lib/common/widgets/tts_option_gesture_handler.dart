import 'dart:async';

import 'package:app/utils/array.dart';
import 'package:app/utils/tts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TtsOptionGestureHandler extends StatefulWidget {
  const TtsOptionGestureHandler({
    required this.child,
    super.key,
  });

  final Widget child;

  static const gestureDetectedCriticalCount = 10;

  @override
  State<TtsOptionGestureHandler> createState() =>
      _TtsOptionGestureHandlerState();
}

class _TtsOptionGestureHandlerState extends State<TtsOptionGestureHandler> {
  ScrollDirection scrollDirection = ScrollDirection.stopped;

  List<double> twoPointerGestureDetectedYList = [];

  List<double> onePointerGestureDetectedYList = [];

  bool isTimerStarted = false;

  Timer? gestureTimer;

  Future<void> _handleGestureResult(
    List<double> targetYList, {
    required FutureOr<void> Function() upwardAction,
    required FutureOr<void> Function() downwardAction,
  }) async {
    var upwardCoordCount = 0;
    var downwardCoordCount = 0;

    var iterCount = 0;
    for (final double currentY in targetYList) {
      if (iterCount == 0) {
        iterCount++;
        continue;
      }

      final diff = currentY - targetYList[iterCount - 1];
      if (diff > 0) {
        downwardCoordCount++;
      } else {
        upwardCoordCount++;
      }

      iterCount++;
    }

    final isUpward = upwardCoordCount > downwardCoordCount;
    final gestureCount = isUpward ? upwardCoordCount : downwardCoordCount;

    if (gestureCount < TtsOptionGestureHandler.gestureDetectedCriticalCount) {
      return;
    }

    if (isUpward) {
      await upwardAction();
      return;
    }

    await downwardAction();
  }

  void startTimer(
    void Function() timeOverExecutor,
  ) {
    if (isTimerStarted) return;

    isTimerStarted = true;

    gestureTimer = Timer(
      const Duration(
        milliseconds: 750,
      ),
      () async {
        timeOverExecutor();

        await Future.delayed(const Duration(milliseconds: 250));

        gestureTimer = null;
        isTimerStarted = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FingerGestureHandler(
      onUpdate: (details, pointerCount) async {
        if (pointerCount == 1) {
          onePointerGestureDetectedYList.add(
            details.globalPosition.dy,
          );
          startTimer(() async {
            await _handleGestureResult(
              onePointerGestureDetectedYList,
              upwardAction: tts.increaseSpeechVolume,
              downwardAction: tts.decreaseSpeechVolume,
            );
            onePointerGestureDetectedYList.clear();
          });
        } else {
          twoPointerGestureDetectedYList.add(
            details.globalPosition.dy,
          );
          startTimer(() async {
            await _handleGestureResult(
              // two pointer is inserted, so use only odd y-coord values
              twoPointerGestureDetectedYList.filter((current, i) => i % 2 == 0),
              upwardAction: tts.increaseSpeechRate,
              downwardAction: tts.decreaseSpeechRate,
            );
            twoPointerGestureDetectedYList.clear();
          });
        }
      },
      child: widget.child,
    );
  }
}

enum ScrollDirection {
  upward,
  downward,
  stopped,
}

class FingerGestureHandler extends StatelessWidget {
  final Widget child;
  final OnUpdate onUpdate;

  const FingerGestureHandler({
    Key? key,
    required this.child,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        CustomVerticalMultiDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                CustomVerticalMultiDragGestureRecognizer>(
          () => CustomVerticalMultiDragGestureRecognizer(debugOwner: null),
          (
            CustomVerticalMultiDragGestureRecognizer instance,
          ) {
            instance.onStart = (Offset position) => DragHandler(
                  pointerEvents: instance.events,
                  onUpdate: onUpdate,
                );
          },
        ),
      },
      child: child,
    );
  }
}

typedef OnUpdate = Function(
  DragUpdateDetails details,
  int pointerCount,
);

class DragHandler extends Drag {
  final List<PointerDownEvent> pointerEvents;

  final OnUpdate onUpdate;

  DragHandler({
    required this.pointerEvents,
    required this.onUpdate,
  });

  @override
  void update(DragUpdateDetails details) {
    super.update(details);
    final delta = details.delta;
    final pointerCount = pointerEvents.length;
    final isOneOrTwoPointerEvent =
        delta.dy.abs() > 0 && (pointerCount == 2 || pointerCount == 1);

    if (isOneOrTwoPointerEvent) {
      onUpdate(
        DragUpdateDetails(
          sourceTimeStamp: details.sourceTimeStamp,
          delta: Offset(0, delta.dy),
          primaryDelta: details.primaryDelta,
          globalPosition: details.globalPosition,
          localPosition: details.localPosition,
        ),
        pointerCount,
      );
    }
  }
}

class CustomVerticalMultiDragGestureRecognizer
    extends MultiDragGestureRecognizer {
  final List<PointerDownEvent> events = [];

  CustomVerticalMultiDragGestureRecognizer({
    required Object? debugOwner,
  }) : super(debugOwner: debugOwner);

  @override
  _CustomVerticalPointerState createNewPointerState(
    PointerDownEvent event,
  ) {
    events.add(event);
    return _CustomVerticalPointerState(
      event.position,
      onDisposeState: () {
        events.remove(event);
      },
    );
  }

  @override
  String get debugDescription => 'custom vertical multi drag';
}

typedef OnDisposeState = Function();

class _CustomVerticalPointerState extends MultiDragPointerState {
  final OnDisposeState onDisposeState;

  _CustomVerticalPointerState(
    Offset initialPosition, {
    required this.onDisposeState,
  }) : super(initialPosition, PointerDeviceKind.touch, null);

  @override
  void checkForResolutionAfterMove() {
    if (pendingDelta!.dy.abs() > kTouchSlop) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    starter(initialPosition);
  }

  @override
  void dispose() {
    onDisposeState.call();
    super.dispose();
  }
}
