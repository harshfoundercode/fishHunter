// import 'dart:math';
// import 'dart:async';
// import 'package:fish_game/generated/assets.dart';
// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:confetti/confetti.dart';
//
// enum SpawnSide { left, right }
//
// class SniperGame2 extends StatefulWidget {
//   const SniperGame2({super.key});
//
//   @override
//   State<SniperGame2> createState() => _SniperGame2State();
// }
//
// class _SniperGame2State extends State<SniperGame2> with TickerProviderStateMixin {
//   // Audio Players
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final AudioPlayer _bgMusicPlayer = AudioPlayer();
//
//   // Game Objects
//   List<Fish> leftFishes = [];
//   List<Fish> rightFishes = [];
//   List<Missile> missiles = [];
//   List<Net> nets = [];
//
//   // Game Control
//   Timer? fishTimer;
//   Timer? gameLoop;
//   Random random = Random();
//   int score = 0;
//   int timeLeft = 60;
//   Timer? countdownTimer;
//   int level = 1;
//   int requiredScore = 60;
//   Timer? levelTimer;
//
//   // UI States
//   bool showLevelPopup = false;
//   bool isPaused = false;
//   bool isSoundOn = true;
//   bool isMusicOn = true;
//
//   // Animation
//   Offset? aimPoint;
//   Offset? coinPosition;
//   bool showCoin = false;
//   // late AnimationController _coinController;
//   List<AnimationController> coinControllers = [];
//   List<Animation<Offset>> coinAnimations = [];
//   late AnimationController _flyCoinController;
//   late Animation<Offset> _flyCoinAnimation;
//
//   // Positions
//   final walletPosition = Offset(12, 12);
//   Offset? missileTarget;
//
//   // Assets
//   List<String> leftFishUrls = ['assets/images/fish11.gif', 'assets/images/fish12.gif'];
//   List<String> rightFishUrls = ['assets/images/fish6.gif'];
//   String blastGif = 'assets/images/blast.gif';
//   String missileUrl = 'assets/images/missile.png';
//   String backgroundUrl = 'assets/images/BG.jpg';
//   String coinImage = 'assets/images/coins.png';
//   String netImage = 'assets/images/net.png';
//
//   String blastSound = 'audio/net_active.ogg';
//   String netSound = 'audio/net_active.ogg';
//   String bgMusic = 'audio/music.mp3';
//   String targetSound = 'audio/coin.mp3';
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _playBackgroundMusic();
//     _startSpawning();
//     _startGameLoop();
//     _startLevelTimer();
//   }
//
//   void _initializeAnimations() {
//     // _coinController = AnimationController(
//     //   vsync: this,
//     //   duration: Duration(milliseconds: 500),
//     // );
//     _flyCoinController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 600),
//     );
//   }
//
//   void _startLevelTimer() {
//     timeLeft = 60;
//     levelTimer?.cancel();
//     countdownTimer?.cancel();
//
//     countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() => timeLeft--);
//       if (timeLeft <= 0) {
//         timer.cancel();
//         _checkLevelCompletion();
//       }
//     });
//
//     levelTimer = Timer(Duration(seconds: 60), _checkLevelCompletion);
//   }
//
//   void _checkLevelCompletion() {
//     if (score >= requiredScore) {
//       _showLevelComplete();
//     } else {
//       _showGameOver();
//     }
//   }
//
//   void _showLevelComplete() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: Text('🎉 Level $level Complete!'),
//         content: Text('Great job! Moving to next level.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() {
//                 level++;
//                 requiredScore += 10;
//                 score = 0;
//                 _startLevelTimer();
//                 _startSpawning();
//               });
//             },
//             child: Text('Next'),
//           )
//         ],
//       ),
//     );
//   }
//
//   void _showGameOver() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: Text('💀 Game Over'),
//         content: Text('You didn\'t reach the required score.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
//             child: Text('Exit'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() {
//                 score = 0;
//                 timeLeft = 60;
//                 _startLevelTimer();
//                 _startSpawning();
//               });
//             },
//             child: Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _playBackgroundMusic() async {
//     await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
//     if (isMusicOn) await _bgMusicPlayer.play(AssetSource(bgMusic));
//   }
//
//   void _startSpawning() {
//     fishTimer?.cancel();
//     fishTimer = Timer.periodic(
//       Duration(milliseconds: (900 - level * 50).clamp(300, 900)),
//           (_) {
//         if (isPaused) return;
//         final screenSize = MediaQuery.of(context).size;
//
//         // Spawn left fish
//         leftFishes.add(Fish(
//           Offset(-60, random.nextDouble() * screenSize.height),
//           leftFishUrls[random.nextInt(leftFishUrls.length)],
//           1.5 + random.nextDouble() * 2 + (level * 0.3),
//           direction: Offset(1, (random.nextDouble() * 2 - 1) * 0.5),
//         ));
//
//         // Spawn right fish
//         rightFishes.add(Fish(
//           Offset(screenSize.width + 60, random.nextDouble() * screenSize.height),
//           rightFishUrls[random.nextInt(rightFishUrls.length)],
//           1.5 + random.nextDouble() * 2 + (level * 0.3),
//           direction: Offset(-1, (random.nextDouble() * 2 - 1) * 0.5),
//         ));
//
//         setState(() {});
//       },
//     );
//   }
//
//   void _startGameLoop() {
//     gameLoop = Timer.periodic(Duration(milliseconds: 30), (_) {
//       if (isPaused) return;
//       _updateFishPositions();
//       _updateMissiles();
//       _updateNets();
//     });
//   }
//
//   void _updateFishPositions() {
//     final screenSize = MediaQuery.of(context).size;
//
//     setState(() {
//       // Move fish that aren't in nets
//       for (var fish in leftFishes) {
//         if (!fish.isInNet && !fish.isHit) {
//           fish.position += fish.direction * fish.speed;
//         }
//       }
//       for (var fish in rightFishes) {
//         if (!fish.isInNet && !fish.isHit) {
//           fish.position += fish.direction * fish.speed;
//         }
//       }
//
//       // Remove fish that are off-screen or hit
//       leftFishes.removeWhere((fish) => fish.position.dx > screenSize.width + 100 || fish.isHit);
//       rightFishes.removeWhere((fish) => fish.position.dx < -100 || fish.isHit);
//     });
//   }
//
//   void _updateMissiles() {
//     setState(() {
//       for (var missile in missiles) {
//         if (!missile.hasReachedTarget) {
//           missile.update();
//
//           // Check if missile reached target position
//           if ((missile.position - missileTarget!).distance < 10) {
//             missile.hasReachedTarget = true;
//             _createNet(missileTarget!);
//           }
//         }
//       }
//
//       missiles.removeWhere((m) => m.hasReachedTarget);
//     });
//   }
//
//   void _updateNets() {
//     nets.removeWhere((net) => net.timer?.isActive == false);
//   }
//
//   // void _createNet(Offset position) {
//   //   final net = Net(center: position, radius: 80);
//   //   nets.add(net);
//   //
//   //   // Play net sound
//   //   if (isSoundOn) _audioPlayer.play(AssetSource(netSound));
//   //
//   //   // Find fish in net area
//   //   for (var fish in [...leftFishes, ...rightFishes]) {
//   //     if (!fish.isHit && (fish.position - position).distance < net.radius) {
//   //       fish.isInNet = true;
//   //       net.caughtFishes.add(fish);
//   //     }
//   //   }
//   //
//   //   // After 0.5 seconds, blast all caught fish
//   //   Timer(Duration(milliseconds: 500), () {
//   //     if (isSoundOn) _audioPlayer.play(AssetSource(blastSound));
//   //
//   //     setState(() {
//   //       // Blast all caught fish
//   //       for (var fish in net.caughtFishes) {
//   //         fish.isHit = true;
//   //       }
//   //     });
//   //
//   //     // After another 0.5 seconds, give rewards
//   //     Timer(Duration(milliseconds: 500), () {
//   //       setState(() {
//   //         score += net.caughtFishes.length;
//   //
//   //         // Show coin animations
//   //         for (int i = 0; i < net.caughtFishes.length; i++) {
//   //           Future.delayed(Duration(milliseconds: i * 200), () {
//   //             setState(() {
//   //               coinPosition = net.center + Offset(
//   //                   random.nextDouble() * 50 - 20,
//   //                   random.nextDouble() * 50 - 25
//   //               );
//   //               showCoin = true;
//   //               _flyCoinAnimation = Tween<Offset>(
//   //                 begin: position,
//   //                 end: walletPosition,
//   //               ).animate(CurvedAnimation(
//   //                 parent: _flyCoinController,
//   //                 curve: Curves.easeInOut,
//   //               ));
//   //
//   //               _flyCoinController.forward(from: 0);
//   //               // _flyCoinController.forward(from: 0);
//   //             });
//   //           });
//   //         }
//   //
//   //         // Remove caught fishes
//   //         leftFishes.removeWhere((fish) => fish.isInNet);
//   //         rightFishes.removeWhere((fish) => fish.isInNet);
//   //       });
//   //     });
//   //   });
//   //
//   //   // Remove net after 2 seconds
//   //   net.timer = Timer(Duration(seconds: 2), () {
//   //     setState(() => nets.remove(net));
//   //   });
//   // }
//
//   void _createNet(Offset position) {
//     final net = Net(center: position, radius: 100);
//     nets.add(net);
//
//     if (isSoundOn) _audioPlayer.play(AssetSource(netSound));
//
//     // Find fish in net area
//     for (var fish in [...leftFishes, ...rightFishes]) {
//       if (!fish.isHit && (fish.position - position).distance < net.radius) {
//         fish.isInNet = true;
//         net.caughtFishes.add(fish);
//       }
//     }
//
//     // After 0.5 seconds, blast all caught fish
//     Timer(Duration(milliseconds: 500), () {
//       if (isSoundOn) _audioPlayer.play(AssetSource(blastSound));
//
//       setState(() {
//         for (var fish in net.caughtFishes) {
//           fish.isHit = true;
//         }
//       });
//
//       // Create coin animations for each fish
//       for (int i = 0; i < net.caughtFishes.length; i++) {
//         final _flyCoinAnimation = AnimationController(
//           vsync: this,
//           duration: Duration(milliseconds: 600),
//         );
//
//         final animation = Tween<Offset>(
//           begin: net.caughtFishes[i].position,
//           end: walletPosition,
//         ).animate(CurvedAnimation(
//           parent: _flyCoinController,
//           curve: Curves.easeInOut,
//         ));
//
//         coinControllers.add(_flyCoinController);
//         coinAnimations.add(animation);
//
//         // Play coin sound for each fish
//         if (isSoundOn) {
//           Future.delayed(Duration(milliseconds: i * 100), () {
//             _audioPlayer.play(AssetSource('audio/coin.mp3'));
//           });
//         }
//
//         _flyCoinAnimation.forward().whenComplete(() {
//           setState(() {
//             coinControllers.remove(_flyCoinAnimation);
//             coinAnimations.remove(animation);
//           });
//         });
//       }
//
//       // Update score
//       setState(() {
//         score += net.caughtFishes.length;
//       });
//
//       // Remove caught fishes
//       leftFishes.removeWhere((fish) => fish.isInNet);
//       rightFishes.removeWhere((fish) => fish.isInNet);
//     });
//
//     // Remove net after 2 seconds
//     net.timer = Timer(Duration(seconds: 2), () {
//       setState(() => nets.remove(net));
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
//     final velocity = Offset(dx / distance * 10, dy / distance * 10);
//
//     setState(() {
//       missileTarget = target;
//       missiles.add(Missile(
//         position: start,
//         velocity: velocity,
//       ));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final launcher = Offset(
//       MediaQuery.of(context).size.width / 2,
//       MediaQuery.of(context).size.height - 40,
//     );
//
//     return Scaffold(
//       body: GestureDetector(
//         onPanUpdate: (details) {
//           if (!isPaused) {
//             setState(() => aimPoint = details.localPosition);
//           }
//         },
//         onTapDown: (details) {
//           if (!isPaused) {
//             final tap = details.localPosition;
//             setState(() => aimPoint = tap);
//             _fireMissile(tap);
//           }
//         },
//         child: Stack(
//           children: [
//             // Background
//             Positioned.fill(
//               child: Image.asset(Assets.imagesBg3, fit: BoxFit.cover),
//             ),
//
//             // Left Fish
//             ...leftFishes.map((fish) => Positioned(
//               left: fish.position.dx,
//               top: fish.position.dy,
//               child: fish.isHit
//                   ? Image.asset(blastGif, height: 60)
//                   : fish.isInNet
//                   ? ColorFiltered(
//                 colorFilter: ColorFilter.mode(
//                   Colors.blue.withOpacity(0.7),
//                   BlendMode.srcATop,
//                 ),
//                 child: Image.asset(fish.imageUrl, height: 60),
//               )
//                   : Image.asset(fish.imageUrl, height: 60),
//             )),
//
//             // Right Fish
//             ...rightFishes.map((fish) => Positioned(
//               left: fish.position.dx,
//               top: fish.position.dy,
//               child: fish.isHit
//                   ? Image.asset(blastGif, height: 60)
//                   : fish.isInNet
//                   ? ColorFiltered(
//                 colorFilter: ColorFilter.mode(
//                   Colors.blue.withOpacity(0.7),
//                   BlendMode.srcATop,
//                 ),
//                 child: Image.asset(fish.imageUrl, height: 60),
//               )
//                   : Image.asset(fish.imageUrl, height: 60),
//             )),
//
//             // Nets
//             ...nets.map((net) => Positioned(
//               left: net.center.dx - net.radius,
//               top: net.center.dy - net.radius,
//               child: Image.asset(
//                 netImage,
//                 width: net.radius * 3,
//                 height: net.radius * 3,
//               ),
//             )),
//
//             // Missiles
//             ...missiles.map((missile) => Positioned(
//               left: missile.position.dx,
//               top: missile.position.dy,
//               child: Transform.rotate(
//                 angle: atan2(missile.velocity.dy, missile.velocity.dx) + pi/2,
//                 child: Image.asset(missileUrl, height: 40),
//               ),
//             )),
//
//             // Aim Line
//             if (aimPoint != null && !isPaused)
//               CustomPaint(
//                 painter: _AimPainter(from: launcher, to: aimPoint!),
//                 child: Container(),
//               ),
//
//             // Coin Animation
//             if (showCoin && coinPosition != null)
//               AnimatedBuilder(
//                 animation: _flyCoinAnimation,
//                 builder: (context, child) {
//                   final position = _flyCoinAnimation.value;
//                   return Positioned(
//                     left: position.dx,
//                     top: position.dy,
//                     child: Image.asset(coinImage, height: 30),
//                   );
//                 },
//               ),
//
//             // Launcher Base
//             Positioned(
//               bottom: -50,
//               left: 45,
//               right: 45,
//               child: Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Image.asset(missileUrl, height: 100),
//               ),
//             ),
//
//             // Score Display
//             Positioned(
//               top: 10,
//               left: 20,
//               child: Row(
//                 children: [
//                   Image.asset(coinImage, height: 30),
//                   SizedBox(width: 8),
//                   Text(
//                     '$score',
//                     style: TextStyle(
//                       fontSize: 24,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       shadows: [Shadow(blurRadius: 8, color: Colors.black)],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Level Display
//             Positioned(
//               top: 10,
//               left: 150,
//               child: Text(
//                 'Level: $level',
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   shadows: [Shadow(blurRadius: 8, color: Colors.black)],
//                 ),
//               ),
//             ),
//
//             // Timer Display
//             Positioned(
//               top: 10,
//               left: 300,
//               child: AnimatedDefaultTextStyle(
//                 duration: Duration(milliseconds: 500),
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: timeLeft <= 10 ? Colors.red : Colors.white,
//                   fontWeight: FontWeight.bold,
//                   shadows: [Shadow(blurRadius: 8, color: Colors.black)],
//                 ),
//                 child: Text('⏱ $timeLeft s'),
//               ),
//             ),
//
//             // Control Buttons
//             Positioned(
//               top: 1,
//               right: 20,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: Icon(
//                       isSoundOn ? Icons.volume_up : Icons.volume_off,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                     onPressed: _toggleSound,
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       isMusicOn ? Icons.music_note : Icons.music_off,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                     onPressed: _toggleMusic,
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       isPaused ? Icons.play_arrow : Icons.pause,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                     onPressed: _togglePause,
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       Icons.exit_to_app,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                     onPressed: _exitGame,
//                   ),
//                 ],
//               ),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _togglePause() {
//     setState(() {
//       isPaused = !isPaused;
//       if (isPaused) {
//         _bgMusicPlayer.pause();
//         fishTimer?.cancel();
//         gameLoop?.cancel();
//       } else {
//         if (isMusicOn) _bgMusicPlayer.resume();
//         _startSpawning();
//         _startGameLoop();
//       }
//     });
//   }
//
//   void _toggleSound() {
//     setState(() => isSoundOn = !isSoundOn);
//   }
//
//   void _toggleMusic() {
//     setState(() {
//       isMusicOn = !isMusicOn;
//       if (isMusicOn) {
//         _playBackgroundMusic();
//       } else {
//         _bgMusicPlayer.pause();
//       }
//     });
//   }
//
//   void _exitGame() {
//     Navigator.of(context).pop();
//   }
//
//   @override
//   void dispose() {
//     fishTimer?.cancel();
//     gameLoop?.cancel();
//     levelTimer?.cancel();
//     _audioPlayer.dispose();
//     _bgMusicPlayer.dispose();
//     _flyCoinController.dispose();
//     super.dispose();
//   }
// }
//
// class _AimPainter extends CustomPainter {
//   final Offset from;
//   final Offset to;
//
//   _AimPainter({required this.from, required this.to});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.7)
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;
//
//     const dashWidth = 10;
//     const dashSpace = 5;
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
//       canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(_AimPainter oldDelegate) => true;
// }
//
// class Fish {
//   Offset position;
//   String imageUrl;
//   double speed;
//   bool isHit;
//   bool isInNet;
//   Offset direction;
//   Fish(this.position, this.imageUrl, this.speed,
//       {this.isHit = false, this.isInNet = false, required this.direction});
// }
//
// class Missile {
//   Offset position;
//   Offset velocity;
//   bool hasExploded;
//   bool hasReachedTarget;
//
//   Missile({
//     required this.position,
//     required this.velocity,
//     this.hasExploded = false,
//     this.hasReachedTarget = false,
//   });
//
//   void update() {
//     position += velocity;
//   }
// }
//
// class Net {
//   Offset center;
//   double radius;
//   Timer? timer;
//   List<Fish> caughtFishes = [];
//
//   Net({required this.center, required this.radius});
// }
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

class Fish {
  Offset position;
  String imageUrl;
  double speed;
  bool isHit;
  bool isInNet;
  Offset direction;
  Fish(this.position, this.imageUrl, this.speed,
      {this.isHit = false, this.isInNet = false, required this.direction});
}

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

class Net {
  Offset center;
  double radius;
  Timer? timer;
  List<Fish> caughtFishes = [];

  Net({required this.center, required this.radius});
}

class CoinAnimation {
  AnimationController controller;
  Animation<Offset> animation;
  Offset position;

  CoinAnimation({
    required this.controller,
    required this.animation,
    required this.position,
  });
}

class SniperGame2 extends StatefulWidget {
  const SniperGame2({super.key});

  @override
  State<SniperGame2> createState() => _SniperGame2State();
}

class _SniperGame2State extends State<SniperGame2> with TickerProviderStateMixin {
  // Game Objects
  List<Fish> leftFishes = [];
  List<Fish> rightFishes = [];
  List<Missile> missiles = [];
  List<Net> nets = [];
  List<CoinAnimation> coinAnimations = [];

  // Game Control
  Timer? fishTimer;
  Timer? gameLoop;
  Random random = Random();
  int score = 0;
  int timeLeft = 60;
  int level = 1;
  int requiredScore = 60;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  bool isSoundOn = true;
  bool isMusicOn = true;
  bool isPaused = false;


  // UI States
  Offset? aimPoint;
  Offset? missileTarget;
  final walletPosition = Offset(12, 12);
  late ConfettiController _confettiController;

  // Assets
  List<String> leftFishUrls = ['assets/images/fish11.gif', 'assets/images/fish12.gif'];
  List<String> rightFishUrls = ['assets/images/fish6.gif'];
  String blastGif = 'assets/images/blast.gif';
  String missileUrl = 'assets/images/missile.png';
  String backgroundUrl = 'assets/images/bg3.png';
  String coinImage = 'assets/images/coins.png';
  String netImage = 'assets/images/net.png';
  String blastSound = 'audio/net_active.ogg';
  String netSound = 'audio/net_active.ogg';
  String coinSound = 'audio/coin.mp3';
  String bgMusic = 'audio/music.mp3';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _playBackgroundMusic();
    _startSpawning();
    _startGameLoop();
    _startLevelTimer();
  }

  void _startLevelTimer() {
    timeLeft = 60;
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => timeLeft--);
      if (timeLeft <= 0) {
        timer.cancel();
        _checkLevelCompletion();
      }
    });
  }

  void _playBackgroundMusic() async {
    await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
    if (isMusicOn) await _bgMusicPlayer.play(AssetSource(bgMusic));
  }

  void _startSpawning() {
    fishTimer = Timer.periodic(
      Duration(milliseconds: (900 - level * 50).clamp(300, 900)),
          (_) {
        if (!mounted || isPaused) return;
        final screenSize = MediaQuery.of(context).size;

        leftFishes.add(Fish(
          Offset(-60, random.nextDouble() * screenSize.height),
          leftFishUrls[random.nextInt(leftFishUrls.length)],
          1.5 + random.nextDouble() * 2 + (level * 0.3),
          direction: Offset(1, (random.nextDouble() * 2 - 1) * 0.5),
        ));

        rightFishes.add(Fish(
          Offset(screenSize.width + 60, random.nextDouble() * screenSize.height),
          rightFishUrls[random.nextInt(rightFishUrls.length)],
          1.5 + random.nextDouble() * 2 + (level * 0.3),
          direction: Offset(-1, (random.nextDouble() * 2 - 1) * 0.5),
        ));

        if (mounted) setState(() {});
      },
    );
  }

  void _startGameLoop() {
    gameLoop = Timer.periodic(Duration(milliseconds: 30), (_) {
      if (!mounted || isPaused) return;
      _updateFishPositions();
      _updateMissiles();
      _updateNets();
      _updateCoinAnimations();
    });
  }

  void _updateFishPositions() {
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      for (var fish in leftFishes) {
        if (!fish.isInNet && !fish.isHit) {
          fish.position += fish.direction * fish.speed;
        }
      }
      for (var fish in rightFishes) {
        if (!fish.isInNet && !fish.isHit) {
          fish.position += fish.direction * fish.speed;
        }
      }

      leftFishes.removeWhere((fish) => fish.position.dx > screenSize.width + 100 || fish.isHit);
      rightFishes.removeWhere((fish) => fish.position.dx < -100 || fish.isHit);
    });
  }

  void _updateMissiles() {
    setState(() {
      for (var missile in missiles) {
        if (!missile.hasReachedTarget) {
          missile.update();

          if ((missile.position - missileTarget!).distance < 10) {
            missile.hasReachedTarget = true;
            _createNet(missileTarget!);
          }
        }
      }

      missiles.removeWhere((m) => m.hasReachedTarget);
    });
  }

  void _updateNets() {
    nets.removeWhere((net) => net.timer?.isActive == false);
  }

  void _updateCoinAnimations() {
    coinAnimations.removeWhere((anim) => !anim.controller.isAnimating);
    if (mounted) setState(() {});
  }

  void _createNet(Offset position) {
    final net = Net(center: position, radius: 100);
    nets.add(net);

    if (isSoundOn) _audioPlayer.play(AssetSource(netSound));

    // Find fish in net area
    for (var fish in [...leftFishes, ...rightFishes]) {
      if (!fish.isHit && (fish.position - position).distance < net.radius) {
        fish.isInNet = true;
        net.caughtFishes.add(fish);
      }
    }

    // After 0.5 seconds, blast all caught fish
    Timer(Duration(milliseconds: 500), () {
      if (isSoundOn) _audioPlayer.play(AssetSource(blastSound));

      setState(() {
        for (var fish in net.caughtFishes) {
          fish.isHit = true;
        }
      });

      // Create coin animations for each fish
      for (int i = 0; i < net.caughtFishes.length; i++) {
        final fish = net.caughtFishes[i];
        final controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 800),
        );

        final animation = Tween<Offset>(
          begin: fish.position,
          end: walletPosition,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ));

        final coinAnim = CoinAnimation(
          controller: controller,
          animation: animation,
          position: fish.position,
        );

        setState(() {
          coinAnimations.add(coinAnim);
        });

        // Play coin sound for each fish with slight delay
        if (isSoundOn) {
          Future.delayed(Duration(milliseconds: i * 150), () {
            _audioPlayer.play(AssetSource(coinSound));
          });
        }

        controller.forward().whenComplete(() {
          if (mounted) {
            setState(() {
              coinAnimations.remove(coinAnim);
            });
          }
          controller.dispose();
        });
      }

      // Update score
      setState(() {
        score += net.caughtFishes.length;
      });

      // Remove caught fishes
      leftFishes.removeWhere((fish) => fish.isInNet);
      rightFishes.removeWhere((fish) => fish.isInNet);
    });

    // Remove net after 2 seconds
    net.timer = Timer(Duration(seconds: 2), () {
      if (mounted) setState(() => nets.remove(net));
    });
  }

  void _fireMissile(Offset target) {
    final start = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height - 40,
    );

    final dx = target.dx - start.dx;
    final dy = target.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final velocity = Offset(dx / distance * 10, dy / distance * 10);

    setState(() {
      missileTarget = target;
      missiles.add(Missile(
        position: start,
        velocity: velocity,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final launcher = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height - 40,
    );

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          if (!isPaused) setState(() => aimPoint = details.localPosition);
        },
        onTapDown: (details) {
          if (!isPaused) {
            final tap = details.localPosition;
            setState(() => aimPoint = tap);
            _fireMissile(tap);
          }
        },
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(backgroundUrl, fit: BoxFit.cover),
            ),

            // Fish
            ...leftFishes.map((fish) => Positioned(
              left: fish.position.dx,
              top: fish.position.dy,
              child: fish.isHit
                  ? Image.asset(blastGif, height: 60)
                  : fish.isInNet
                  ? ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.blue.withOpacity(0.7),
                  BlendMode.srcATop,
                ),
                child: Image.asset(fish.imageUrl, height: 60),
              )
                  : Image.asset(fish.imageUrl, height: 60),
            )),

            ...rightFishes.map((fish) => Positioned(
              left: fish.position.dx,
              top: fish.position.dy,
              child: fish.isHit
                  ? Image.asset(blastGif, height: 60)
                  : fish.isInNet
                  ? ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.blue.withOpacity(0.7),
                  BlendMode.srcATop,
                ),
                child: Image.asset(fish.imageUrl, height: 60),
              )
                  : Image.asset(fish.imageUrl, height: 60),
            )),

            // Nets
            ...nets.map((net) => Positioned(
              left: net.center.dx - net.radius,
              top: net.center.dy - net.radius,
              child: Image.asset(
                netImage,
                width: net.radius * 3,
                height: net.radius * 3,
              ),
            )),

            // Missiles
            ...missiles.map((missile) => Positioned(
              left: missile.position.dx,
              top: missile.position.dy,
              child: Transform.rotate(
                angle: atan2(missile.velocity.dy, missile.velocity.dx) + pi/2,
                child: Image.asset(coinImage, height: 40),
              ),
            )),

            // Coin Animations
            ...coinAnimations.map((anim) => AnimatedBuilder(
              animation: anim.animation,
              builder: (context, child) {
                return Positioned(
                  left: anim.animation.value.dx,
                  top: anim.animation.value.dy,
                  child: Image.asset(coinImage, height: 30),
                );
              },
            )),

            // // Aim Line
            // if (aimPoint != null)
            //   CustomPaint(
            //     painter: _AimPainter(from: launcher, to: aimPoint!),
            //     child: Container(),
            //   ),

            // Launcher Base
            Positioned(
              bottom: -50,
              left: 45,
              right: 45,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(missileUrl, height: 100),
              ),
            ),

            // Score Display
            Positioned(
              top: 10,
              left: 20,
              child: Row(
                children: [
                  Image.asset(coinImage, height: 30),
                  SizedBox(width: 8),
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                    ),
                  ),
                ],
              ),
            ),

            // Level Display
            Positioned(
              top: 10,
              left: 150,
              child: Text(
                'Level: $level',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                ),
              ),
            ),

            // Timer Display
            Positioned(
              top: 10,
              left: 300,
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 500),
                style: TextStyle(
                  fontSize: 24,
                  color: timeLeft <= 10 ? Colors.red : Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                ),
                child: Text('⏱ $timeLeft s'),
              ),
            ),

            // Control Buttons
            Positioned(
              top: 1,
              right: 20,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isSoundOn ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed:(){
                      _toggleSound(context);
                      print("fcbjhrgvuicf");
                    } ,
                  ),
                  IconButton(
                    icon: Icon(
                      isMusicOn ? Icons.music_note : Icons.music_off,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: (){
                      _toggleMusic(context);
                      print("wdugwigdw");
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed:(){
                      _togglePause(context);
                    } ,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _exitGame,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePause(context) {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        _bgMusicPlayer.pause();
        fishTimer?.cancel();
        gameLoop?.cancel();
      } else {
        if (isMusicOn) _bgMusicPlayer.resume();
        _startSpawning();
        _startGameLoop();
      }
    });
  }

  void _toggleSound(context) => setState(() => isSoundOn = !isSoundOn);


  Future<void> _toggleMusic(context) async {
    setState(() {
      isMusicOn = !isMusicOn;
    });

    if (isMusicOn) {
      await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgMusicPlayer.play(AssetSource(bgMusic));
    } else {
      // await _bgMusicPlayer.pause();
      // Alternatively, you could use stop() for complete reset
      await _bgMusicPlayer.stop();
    }
  }

  void _exitGame() => Navigator.of(context).pop();

  void _checkLevelCompletion() {
    if (score >= requiredScore) {
      _showLevelComplete();
    } else {
      _showGameOver();
    }
  }

  void _showLevelComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('🎉 Level $level Complete!'),
        content: Text('Great job! Moving to next level.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                level++;
                requiredScore += 10;
                score = 0;
                _startLevelTimer();
                _startSpawning();
              });
            },
            child: Text('Next'),
          )
        ],
      ),
    );
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('💀 Game Over'),
        content: Text('You didn\'t reach the required score.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Text('Exit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                score = 0;
                timeLeft = 60;
                _startLevelTimer();
                _startSpawning();
              });
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    fishTimer?.cancel();
    gameLoop?.cancel();
    _audioPlayer.dispose();
    _bgMusicPlayer.dispose();
    for (var anim in coinAnimations) {
      anim.controller.dispose();
    }
    _confettiController.dispose();
    super.dispose();
  }
}

