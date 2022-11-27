import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:object_detection_app/logic/detector/recognition.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as ImageLib;

class ObjectDetector {
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

  ObjectDetector({Interpreter? interpreter, List<String>? labels}){
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
      for (var tensor in outputTensors) {
        _outputShapes!.add(tensor.shape);
        _outputTypes!.add(tensor.type);
      }
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
    int padSize = max(image.height, image.width);
    _imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(padSize, padSize))
        .add(ResizeOp(_inputShapes![0][1], _inputShapes![0][2], ResizeMethod.BILINEAR))
        .build();
    return _imageProcessor!.process(image);
  }

  Map<String, dynamic> predict(ImageLib.Image image) {
      TensorImage tensorImage = TensorImage(_inputTypes![0]);
      tensorImage.loadImage(image);
      TensorImage inputImage = getProcessedImage(tensorImage);

      TensorBuffer outputLocations = TensorBufferFloat(_outputShapes![0]);
      TensorBuffer outputClasses = TensorBufferFloat(_outputShapes![1]);
      TensorBuffer outputScores = TensorBufferFloat(_outputShapes![2]);
      TensorBuffer numLocations = TensorBufferFloat(_outputShapes![3]);

      List<Object> inputs = [inputImage.buffer];
      Map<int, Object> outputs = {
        0: outputLocations.buffer,
        1: outputClasses.buffer,
        2: outputScores.buffer,
        3: numLocations.buffer
      };

      _interpreter!.runForMultipleInputs(inputs, outputs);

      List<Rect> locations = BoundingBoxUtils.convert(
          tensor: outputLocations,
          boundingBoxAxis: 2,
          boundingBoxType: BoundingBoxType.BOUNDARIES,
          coordinateType: CoordinateType.PIXEL,
          height: INPUT_SIZE,
          width: INPUT_SIZE
      );

      int numResults = min(NUM_RESULTS, numLocations.getIntValue(0));

      List<Recognition> recognitions = [];

      for (int i = 0; i < numResults; ++i) {
        var score = outputScores.getDoubleValue(i);
        var labelIndex = outputClasses.getIntValue(i) + 1;
        var label = _labels!.elementAt(labelIndex);

        if (score > THRESHOLD) {
          Rect transformedRect = _imageProcessor!.inverseTransformRect(
              locations[i], INPUT_SIZE, INPUT_SIZE
          );
          recognitions.add(Recognition(i, label, score, transformedRect));
        }

      }

      return {
        "recognitions": recognitions
    };
  }

  Interpreter? get interpreter => _interpreter;
  List<String>? get labels => _labels;
}