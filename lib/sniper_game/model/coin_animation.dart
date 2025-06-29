import 'package:flutter/animation.dart';

class CoinAnimation {
  final AnimationController controller;
  final Animation<Offset> animation;
  final Animation<double> rotation;
  final Animation<double> scale;
  final Offset start;

  CoinAnimation({
    required this.controller,
    required this.animation,
    required this.rotation,
    required this.scale,
    required this.start,

  });
}
