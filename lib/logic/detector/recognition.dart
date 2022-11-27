import 'dart:math';
import 'dart:ui';

class Recognition {
  final int _id;
  final String _label;
  final double _confidence;
  final Rect _location;

  Recognition(this._id, this._label,  this._confidence, this._location);

  int get id => _id;
  String get label => _label;
  double get confidence => _confidence;
  Rect get location => _location;

  Rect getRenderLocation(double screenWidth, double screenHeight, double imageInputWidth) {
    double ratioX = 1;
    double ratioY = ratioX;
    
    double transLeft = max(0.1, location.left * ratioX);
    double transTop = max(0.1, location.top * ratioY);
    double transWidth = min(location.width * ratioX, screenWidth);
    double transHeight = min(location.height * ratioY, screenHeight);

    Rect transformedRect = Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);
    return transformedRect;
  }
}