import 'package:fish_game/sniper_game/model/fish_model.dart';
import 'package:flutter/material.dart';

class FishWidget extends StatelessWidget {
  final Fish fish;
  final String blastGif;

  const FishWidget({super.key, required this.fish, required this.blastGif});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: fish.position.dx,
      top: fish.position.dy,
      child: fish.isHit
          ? Image.asset(blastGif, height: 50)
          : fish.isInNet
          ? ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.blue.withOpacity(0.7), BlendMode.srcATop),
        child: Image.asset(fish.imageUrl, height: 50),
      )
          : Image.asset(fish.imageUrl, height: 50),
    );
  }
}
