import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:object_detection_app/logic/detector/object_detector.dart';

import '../detector/recognition.dart';

part 'image_loader_state.dart';

class ImageLoaderCubit extends Cubit<ImageLoaderState> {
  ImageLoaderCubit() : super(ImageLoaderState(imagePath: ''));

  void loadImage() async {
    var imagePicker = ImagePicker();
    var objectDetector = Classifier();

    dynamic image;
    try {
      image = await imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 300, maxHeight: 300, preferredCameraDevice: CameraDevice.front, requestFullMetadata: false);
    } catch (e) {
      image = null;
    }
    if (image == null) {
      emit(ImageLoaderState(imagePath: ''));
    }
    else {
      var imgFile = File(image!.path);
      Map<String, dynamic>? recognitions = objectDetector.predict(img.decodeImage(imgFile!.readAsBytesSync())!);
      emit(ImageLoaderState(imagePath: image!.path, recognitions: recognitions!['recognitions']));
    }
  }

}