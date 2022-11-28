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
}