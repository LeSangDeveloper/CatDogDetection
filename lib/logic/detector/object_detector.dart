import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:object_detection_app/logic/detector/recognition.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as ImageLib;

class Classifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const String MODEL_FILE_NAME = "detect.tflite";
  static const String LABEL_FILE_NAME = "labelmap.txt";
  static const int INPUT_SIZE = 300;
  static const int NUM_RESULTS = 10;
  static const double THRESHOLD = 0.5;

  List<List<int>>? _outputShapes;
  List<TfLiteType>? _outputTypes;
  List<List<int>>? _inputShapes;
  List<TfLiteType>? _inputTypes;

  ImageProcessor? _imageProcessor;

  Classifier({Interpreter? interpreter, List<String>? labels}){
    loadModel(interpreter);
    loadLabels(labels);
  }

  void loadModel(Interpreter? interpreter) async {
    try {
      _interpreter = interpreter ?? await Interpreter.fromAsset(MODEL_FILE_NAME);
      var outputTensors = _interpreter!.getOutputTensors();
      var inputTensors = _interpreter!.getInputTensors();
      _outputShapes = [];
      _outputTypes = [];
      _inputShapes = [];
      _inputTypes = [];
      outputTensors.forEach((tensor) {
        _outputShapes!.add(tensor.shape);
        _outputTypes!.add(tensor.type);
      });
      for (var tensor in inputTensors) {
        _inputShapes!.add(tensor.shape);
        _inputTypes!.add(tensor.type);
      }
    } catch (e) {
      debugPrint("Cannot load the model $e");
    }
  }

  void loadLabels(List<String>? labels) async {
    try {
      _labels = labels ?? await FileUtil.loadLabels("assets/$LABEL_FILE_NAME");
    } catch(e) {
      debugPrint("Cannot load labels $e");
    }
  }

  TensorImage getProcessedImage(TensorImage image) {
    var padSize = max(image.height, image.width);
    _imageProcessor = ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(padSize, padSize))
          .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
          .build();
    image = _imageProcessor!.process(image);
    return image;
  }

  Map<String, dynamic>? predict(ImageLib.Image image) {
    var predictStartTime = DateTime.now().millisecondsSinceEpoch;

    if (_interpreter == null) {
      print("Interpreter not initialized");
      return null;
    }

    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    // Create TensorImage from image
    TensorImage inputImage = TensorImage.fromImage(image);

    // Pre-process TensorImage
    inputImage = getProcessedImage(inputImage);

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;

    // TensorBuffers for output tensors
    TensorBuffer outputLocations = TensorBufferFloat(_outputShapes![0]);
    TensorBuffer outputClasses = TensorBufferFloat(_outputShapes![1]);
    TensorBuffer outputScores = TensorBufferFloat(_outputShapes![2]);
    TensorBuffer numLocations = TensorBufferFloat(_outputShapes![3]);

    // Inputs object for runForMultipleInputs
    // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    List<Object> inputs = [inputImage.buffer];

    // Outputs map
    Map<int, Object> outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };

    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    // run inference
    _interpreter!.runForMultipleInputs(inputs, outputs);

    var inferenceTimeElapsed =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;

    // Maximum number of results to show
    int resultsCount = min(NUM_RESULTS, numLocations.getIntValue(0));

    // Using labelOffset = 1 as ??? at index 0
    int labelOffset = 1;

    // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.RATIO,
      height: INPUT_SIZE,
      width: INPUT_SIZE,
    );

    List<Recognition> recognitions = [];

    for (int i = 0; i < resultsCount; i++) {
      // Prediction score
      var score = outputScores.getDoubleValue(i);

      // Label string
      var labelIndex = outputClasses.getIntValue(i) + labelOffset;
      var label = _labels!.elementAt(labelIndex);

      if (score > THRESHOLD) {
        // inverse of rect
        // [locations] corresponds to the image size 300 X 300
        // inverseTransformRect transforms it our [inputImage]
        Rect transformedRect = _imageProcessor!.inverseTransformRect(
            locations[i], image.height, image.width);

        recognitions.add(
          Recognition(i, label, score, transformedRect),
        );
      }
    }

    var predictElapsedTime =
        DateTime.now().millisecondsSinceEpoch - predictStartTime;

    return {
      "recognitions": recognitions
    };
  }

  Interpreter? get interpreter => _interpreter;
  List<String>? get labels => _labels;
}