import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Detector {
  /// Instance of Interpreter
  late final Interpreter _interpreter;

  /// Labels file loaded as list
  late final List<String> _labels;

  static const String modelName = "menu-detector.tflite";
  static const String labelName = "label.txt";

  /// Input size of image (Mobilenetv2: 224 x 224)
  static const int inputSize = 224;

  /// Result score threshold
  static const double threshold = 0.5;

  /// [ImageProcessor] used to pre-process the image
  late final ImageProcessor imageProcessor;

  /// Padding the image to transform into square
  late final int padSize;

  /// Shapes of output tensors
  late final List<List<int>> _outputShapes;

  /// Types of output tensors
  late final List<TfLiteType> _outputTypes;

  /// Number of results to show
  static const int numResults = 1;

  Detector({
    required Interpreter interpreter,
    required List<String> labels,
  }) {
    loadModel(interpreter: interpreter);
    loadLabels(labels: labels);
  }

  /// Loads interpreter from asset
  Future<void> loadModel({required Interpreter interpreter}) async {
    try {
      _interpreter = await Interpreter.fromAsset(
        modelName,
        options: InterpreterOptions()..threads = 4,
      );

      final outputTensors = _interpreter.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      for (final tensor in outputTensors) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      }
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Loads labels from assets
  Future<void> loadLabels({required List<String> labels}) async {
    try {
      _labels = await FileUtil.loadLabels("assets/$labelName");
    } catch (e) {
      print("Error while loading labels: $e");
    }
  }

  /// Pre-process the image
  TensorImage getProcessedImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);
    return imageProcessor.process(inputImage);
  }

  /// Runs object detection on the input image
  Map<String, dynamic> predict(img.Image image) {
    // Create TensorImage from image
    TensorImage inputImage = TensorImage.fromImage(image);

    // Pre-process TensorImage
    inputImage = getProcessedImage(inputImage);

    // TensorBuffers for output tensors
    final TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[0]);
    final TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[1]);
    final TensorBuffer outputScores = TensorBufferFloat(_outputShapes[2]);
    final TensorBuffer numLocations = TensorBufferFloat(_outputShapes[3]);

    // Inputs object for runForMultipleInputs
    // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    final List<Object> inputs = [inputImage.buffer];

    // Outputs map
    final Map<int, Object> outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };

    // run inference
    _interpreter.runForMultipleInputs(inputs, outputs);

    // Maximum number of results to show
    final int resultsCount = min(numResults, numLocations.getIntValue(0));

    // Using labelOffset = 1 as ??? at index 0
    const int labelOffset = 1;

    // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
    final List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.RATIO,
      height: inputSize,
      width: inputSize,
    );

    //final List<Recognition> recognitions = [];

    for (int i = 0; i < resultsCount; i++) {
      // Prediction score
      final score = outputScores.getDoubleValue(i);

      // Label string
      final labelIndex = outputClasses.getIntValue(i) + labelOffset;
      final label = _labels.elementAt(labelIndex);

      if (score > threshold) {
        // inverse of rect
        // [locations] corresponds to the image size 300 X 300
        // inverseTransformRect transforms it our [inputImage]
        final Rect transformedRect = imageProcessor.inverseTransformRect(
            locations[i], image.height, image.width);

        // recognitions.add(
        //   Recognition(i, label, score, transformedRect),
        // );
      }
    }

    return {
      // "recognitions": recognitions,
    };
  }

  /// Gets the interpreter instance
  Interpreter get interpreter => _interpreter;

  /// Gets the loaded labels
  List<String> get labels => _labels;
}
