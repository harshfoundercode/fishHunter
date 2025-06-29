import 'dart:async';
import 'dart:ui';

import 'fish_model.dart';

class Net {
  Offset center;
  double radius;
  Timer? timer;
  List<Fish> caughtFishes = [];

  Net({required this.center, required this.radius});
}