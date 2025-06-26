// import 'dart:async';
// import 'dart:math';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// enum SpawnSide { left, right, top, bottom }
// class Fish {
//   Offset position;
//   String imageUrl;
//   double speed;
//   bool isHit;
//   Offset direction;
//   Fish(this.position, this.imageUrl, this.speed, {this.isHit = false, required this.direction});
// }
//
// class Missile {
//   Offset position;
//   Offset velocity;
//
//   Missile({required this.position, required this.velocity});
//
//   void update() {
//     position += velocity;
//   }
//
//   void bounceIfNeeded(Size size) {
//     if (position.dx <= 0 || position.dx >= size.width - 30) {
//       velocity = Offset(-velocity.dx, velocity.dy);
//     }
//     if (position.dy <= 0) {
//       velocity = Offset(velocity.dx, -velocity.dy);
//     }
//   }
// }
//
// class FishGameScreen extends StatefulWidget {
//   const FishGameScreen({super.key});
//
//   @override
//   State<FishGameScreen> createState() => _FishGameScreenState();
// }
//
// class _FishGameScreenState extends State<FishGameScreen> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final AudioPlayer _bgMusicPlayer = AudioPlayer();
//
//   List<Fish> fishes = [];
//   List<Missile> missiles = [];
//   Timer? fishTimer;
//   Timer? gameLoop;
//   Random random = Random();
//   int score = 0;
//
//   bool isPaused = false;
//   bool isSoundOn = true;
//   bool isMusicOn = true;
//
//   Offset? aimPoint;
//
//   List<String> fishUrls = [
//     'assets/images/fish6.gif',
//     'assets/images/fish6.gif',
//     'assets/images/fish6.gif',
//   ];
//
//   String blastGif = 'assets/images/blast.gif';
//   String missileUrl = 'assets/images/missile.png';
//   String backgroundUrl = 'assets/images/BG.jpg';
//
//   @override
//   void initState() {
//     super.initState();
//     _playBackgroundMusic();
//     _startSpawning();
//     _startGameLoop();
//   }
//
//   void _playBackgroundMusic() async {
//     await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
//     if (isMusicOn) {
//       await _bgMusicPlayer.play(AssetSource('audio/music.mp3'));
//     }
//   }
//
//   void _startSpawning() {
//     fishTimer = Timer.periodic(Duration(milliseconds: 900), (_) {
//       if (isPaused) return;
//       final screenSize = MediaQuery.of(context).size;
//       final spawnSide = SpawnSide.values[random.nextInt(SpawnSide.values.length)];
//
//       Offset position;
//       Offset direction;
//       String fishImage = fishUrls[random.nextInt(fishUrls.length)];
//       double speed = 1.5 + random.nextDouble() * 2;
//
//       switch (spawnSide) {
//         case SpawnSide.left:
//           position = Offset(-60, random.nextDouble() * screenSize.height);
//           direction = Offset(1, (random.nextDouble() * 2 - 1) * 0.5); // Move right with some vertical variation
//           break;
//         case SpawnSide.right:
//           position = Offset(screenSize.width + 60, random.nextDouble() * screenSize.height);
//           direction = Offset(-1, (random.nextDouble() * 2 - 1) * 0.5); // Move left with some vertical variation
//           break;
//         case SpawnSide.top:
//           position = Offset(random.nextDouble() * screenSize.width, -60);
//           direction = Offset((random.nextDouble() * 2 - 1) * 0.5, 1); // Move down with some horizontal variation
//           break;
//         case SpawnSide.bottom:
//           position = Offset(random.nextDouble() * screenSize.width, screenSize.height + 60);
//           direction = Offset((random.nextDouble() * 2 - 1) * 0.5, -1); // Move up with some horizontal variation
//           break;
//       }
//
//       setState(() {
//         fishes.add(Fish(position, fishImage, speed, direction: direction));
//       });
//     });
//   }
//
//   void _startGameLoop() {
//     gameLoop = Timer.periodic(Duration(milliseconds: 30), (_) {
//       if (isPaused) return;
//       _updateFishPositions();
//       _updateMissiles();
//     });
//   }
//
//   void _updateFishPositions() {
//     setState(() {
//       for (var fish in fishes) {
//         fish.position += fish.direction * fish.speed;
//       }
//       final screenSize = MediaQuery.of(context).size;
//       fishes.removeWhere((fish) {
//         return fish.position.dx < -100 ||
//             fish.position.dx > screenSize.width + 100 ||
//             fish.position.dy < -100 ||
//             fish.position.dy > screenSize.height + 100 ||
//             fish.isHit;
//       });
//     });
//   }
//
//   void _updateMissiles() {
//     setState(() {
//       for (var missile in missiles) {
//         missile.update();
//       }
//
//       for (var missile in missiles) {
//         for (var fish in fishes) {
//           if (!fish.isHit &&
//               (fish.position - missile.position).distance < 30) {
//             fish.isHit = true;
//             score++;
//             if (isSoundOn) {
//               _audioPlayer.play(AssetSource('audio/blastsound.mp3'));
//             }
//             missile.position = Offset(-9999, -9999); // remove missile
//
//             Future.delayed(Duration(milliseconds: 400), () {
//               setState(() {
//                 fishes.removeWhere((f) => f.isHit);
//               });
//             });
//           }
//         }
//       }
//
//       missiles.removeWhere((m) =>
//       m.position.dy > MediaQuery.of(context).size.height + 30 ||
//           m.position.dy < -30);
//     });
//   }
//
//   void _fireMissile(Offset target) {
//     final start = Offset(
//       MediaQuery.of(context).size.width / 2,
//       MediaQuery.of(context).size.height - 40,
//     );
//
//     final dx = target.dx - start.dx;
//     final dy = target.dy - start.dy;
//     final distance = sqrt(dx * dx + dy * dy);
//     final velocity = Offset(dx / distance * 6, dy / distance * 6);
//
//     setState(() {
//       missiles.add(Missile(position: start, velocity: velocity));
//     });
//   }
//
//   double getAngle(Offset from, Offset to) {
//     final dx = to.dx - from.dx;
//     final dy = to.dy - from.dy;
//     return atan2(dy, dx); // radians
//   }
//
//   void _togglePause() {
//     setState(() {
//       isPaused = !isPaused;
//     });
//   }
//
//   @override
//   void dispose() {
//     fishTimer?.cancel();
//     gameLoop?.cancel();
//     _audioPlayer.dispose();
//     _bgMusicPlayer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final launcher = Offset(
//       MediaQuery.of(context).size.width / 2,
//       MediaQuery.of(context).size.height - 40,
//     );
//
//     return GestureDetector(
//       onPanUpdate: (details) {
//         if (!isPaused) {
//           setState(() {
//             aimPoint = details.localPosition;
//           });
//         }
//       },
//       onTapDown: (details) {
//         if (!isPaused) {
//           aimPoint = details.localPosition;
//           _fireMissile(aimPoint!);
//         }
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             // Background
//             Positioned.fill(
//               child: Image.asset(backgroundUrl, fit: BoxFit.cover),
//             ),
//
//             // Fishes
//             ...fishes.map((fish) => Positioned(
//               left: fish.position.dx,
//               top: fish.position.dy,
//               child: Transform(
//                 alignment: Alignment.center,
//                 transform: Matrix4.identity()
//                   ..scale(fish.direction.dx < 0 ? -1.0 : 1.0, 1.0), // Flip horizontally if moving left
//                 child: fish.isHit
//                     ? Image.asset(blastGif, height: 60)
//                     : Image.asset(fish.imageUrl, height: 60),
//               ),
//             )),
//             // Aiming Line
//             if (aimPoint != null && !isPaused)
//               CustomPaint(
//                 painter: AimPainter(from: launcher, to: aimPoint!),
//                 child: Container(),
//               ),
//
//             // Missiles
//             ...missiles.map((m) => Positioned(
//               left: m.position.dx,
//               top: m.position.dy,
//               child: Image.asset(missileUrl, height: 30),
//             )),
//
//             // Rotating Launcher
//             Positioned(
//               bottom: 20,
//               left: launcher.dx - 30,
//               child: Transform.rotate(
//                 angle: aimPoint != null ? getAngle(launcher, aimPoint!) : 0,
//                 child: Image.asset(missileUrl, height: 60),
//               ),
//             ),
//
//             // Score
//             Positioned(
//               top: 30,
//               left: 20,
//               child: Text(
//                 'Score: $score',
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   shadows: [Shadow(blurRadius: 8, color: Colors.black)],
//                 ),
//               ),
//             ),
//
//             // Controls
//             Positioned(
//               top: 30,
//               right: 20,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: Icon(
//                       isPaused ? Icons.play_arrow : Icons.pause,
//                       color: Colors.white,
//                     ),
//                     onPressed: _togglePause,
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       isMusicOn ? Icons.music_note : Icons.music_off,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       setState(() => isMusicOn = !isMusicOn);
//                       isMusicOn
//                           ? _playBackgroundMusic()
//                           : _bgMusicPlayer.stop();
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       isSoundOn ? Icons.volume_up : Icons.volume_off,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       setState(() => isSoundOn = !isSoundOn);
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.close, color: Colors.white),
//                     onPressed: () {
//                       _bgMusicPlayer.stop();
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class AimPainter extends CustomPainter {
//   final Offset from;
//   final Offset to;
//
//   AimPainter({required this.from, required this.to});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;
//
//     const dashWidth = 6;
//     const dashSpace = 6;
//     final dx = to.dx - from.dx;
//     final dy = to.dy - from.dy;
//     final distance = sqrt(dx * dx + dy * dy);
//     final steps = (distance / (dashWidth + dashSpace)).floor();
//
//     for (int i = 0; i < steps; i++) {
//       final startX = from.dx + (i * (dashWidth + dashSpace)) * dx / distance;
//       final startY = from.dy + (i * (dashWidth + dashSpace)) * dy / distance;
//       final endX = startX + (dashWidth * dx / distance);
//       final endY = startY + (dashWidth * dy / distance);
//
//       canvas.drawLine(
//         Offset(startX, startY),
//         Offset(endX, endY),
//         paint,
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
