import 'dart:math';
import 'package:fish_game/sniper_game/model/missile_model.dart';
import 'package:flutter/material.dart';

class MissileWidget extends StatelessWidget {
  final Missile missile;
  final String missileAsset;

  const MissileWidget({super.key, required this.missile, required this.missileAsset});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: missile.position.dx,
      top: missile.position.dy,
      child: Transform.rotate(
        angle: atan2(missile.velocity.dy, missile.velocity.dx) + pi / 2,
        child: Image.asset(missileAsset, height: 40),
      ),
    );
  }
}
