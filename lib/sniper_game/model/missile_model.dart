import 'dart:ui';

class Missile {
  Offset position;
  Offset velocity;
  bool hasReachedTarget;

  Missile({
    required this.position,
    required this.velocity,
    this.hasReachedTarget = false,
  });

  void update() {
    position += velocity;
  }
}
