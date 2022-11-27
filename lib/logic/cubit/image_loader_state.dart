part of 'image_loader_cubit.dart';

class ImageLoaderState {
  String imagePath;
  List<Recognition>? recognitions;

  ImageLoaderState({
    required this.imagePath,
    this.recognitions
  });
}