import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

part 'image_loader_state.dart';

class ImageLoaderCubit extends Cubit<ImageLoaderState> {
  ImageLoaderCubit() : super(ImageLoaderState(imagePath: ''));

  void loadImage() async {
    var imagePicker = ImagePicker();
    dynamic image;
    try {
      image = await imagePicker.pickImage(source: ImageSource.gallery, maxHeight: 300, preferredCameraDevice: CameraDevice.front, requestFullMetadata: false);
    } catch (e) {
      image = null;
    }
    if (image == null) {
      emit(ImageLoaderState(imagePath: ''));
    }
    else {
      emit(ImageLoaderState(imagePath: image!.path));
    }
  }

}