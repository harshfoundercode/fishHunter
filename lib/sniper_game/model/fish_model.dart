import 'dart:ui';

class Fish {
  Offset position;
  String imageUrl;
  double speed;
  bool isHit;
  bool isInNet;
  Offset direction;
  Fish(
    this.position,
    this.imageUrl,
    this.speed, {
    this.isHit = false,
    this.isInNet = false,
    required this.direction,
  });
}
