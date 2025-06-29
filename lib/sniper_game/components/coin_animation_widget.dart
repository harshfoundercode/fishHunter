import 'package:fish_game/sniper_game/model/coin_animation.dart';
import 'package:flutter/material.dart';

class CoinAnimationWidget extends StatelessWidget {
  final CoinAnimation coinAnim;
  final String coinImage;

  const CoinAnimationWidget({super.key, required this.coinAnim, required this.coinImage});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: coinAnim.controller,
      builder: (context, child) {
        return Positioned(
          left: coinAnim.animation.value.dx,
          top: coinAnim.animation.value.dy,
          child: Transform.rotate(
            angle: coinAnim.rotation.value,
            child: Transform.scale(
              scale: coinAnim.scale.value,
              child: Image.asset(coinImage, height: 35),
            ),
          ),
        );
      },
    );
  }
}
