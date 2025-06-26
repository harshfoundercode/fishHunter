// import 'dart:async';
// import 'dart:math';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
//
// enum SpawnSide { left, right }
//
// class Fish {
//   Offset position;
//   String imageUrl;
//   double speed;
//   bool isHit;
//   Offset direction;
//   Fish(
//     this.position,
//     this.imageUrl,
//     this.speed, {
//     this.isHit = false,
//     required this.direction,
//   });
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
// }
//
// class SniperScreen extends StatefulWidget {
//   const SniperScreen({super.key});
//
//   @override
//   State<SniperScreen> createState() => _SniperScreenState();
// }
//
// class _SniperScreenState extends State<SniperScreen>
//     with TickerProviderStateMixin {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final AudioPlayer _bgMusicPlayer = AudioPlayer();
//   final AudioPlayer _coinSoundPlayer = AudioPlayer();
//
//   List<Fish> leftFishes = [];
//   List<Fish> rightFishes = [];
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
//   Offset? coinPosition;
//   bool showCoin = false;
//   late AnimationController _coinController;
//   late AnimationController _flyCoinController;
//   late Animation<Offset> _flyCoinAnimation;
//   late AnimationController _walletAnimationController;
//
//   final walletPosition = Offset(60, 40);
//
//   // LEFT side fish GIFs
//   List<String> leftFishUrls = [
//     'assets/images/fish11.gif',
//     'assets/images/fish12.gif',
//     'assets/images/fish12.gif',
//   ];
//
//   // RIGHT side fish GIFs
//   List<String> rightFishUrls = [
//     'assets/images/fish6.gif',
//     'assets/images/fish6.gif',
//     'assets/images/fish6.gif',
//   ];
//
//   String blastGif = 'assets/images/blast.gif';
//   String missileUrl = 'assets/images/missile.png';
//   String backgroundUrl = 'assets/images/BG.jpg';
//   String coinImage = 'assets/images/coins.png';
//
//   @override
//   void initState() {
//     super.initState();
//     _coinController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     );
//     _flyCoinController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 600),
//     );
//     _walletAnimationController =
//         AnimationController(
//           vsync: this,
//           duration: Duration(milliseconds: 200),
//           lowerBound: 1.0,
//           upperBound: 1.4,
//         )..addStatusListener((status) {
//           if (status == AnimationStatus.completed) {
//             _walletAnimationController.reverse();
//           }
//         });
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
//
//       Offset leftPos = Offset(-60, random.nextDouble() * screenSize.height);
//       Offset leftDir = Offset(1, (random.nextDouble() * 2 - 1) * 0.5);
//       String leftImage = leftFishUrls[random.nextInt(leftFishUrls.length)];
//       double leftSpeed = 1.5 + random.nextDouble() * 2;
//       leftFishes.add(Fish(leftPos, leftImage, leftSpeed, direction: leftDir));
//
//       Offset rightPos = Offset(
//         screenSize.width + 60,
//         random.nextDouble() * screenSize.height,
//       );
//       Offset rightDir = Offset(-1, (random.nextDouble() * 2 - 1) * 0.5);
//       String rightImage = rightFishUrls[random.nextInt(rightFishUrls.length)];
//       double rightSpeed = 1.5 + random.nextDouble() * 2;
//       rightFishes.add(
//         Fish(rightPos, rightImage, rightSpeed, direction: rightDir),
//       );
//
//       setState(() {});
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
//     final screenSize = MediaQuery.of(context).size;
//
//     setState(() {
//       for (var fish in leftFishes) {
//         fish.position += fish.direction * fish.speed;
//       }
//       for (var fish in rightFishes) {
//         fish.position += fish.direction * fish.speed;
//       }
//
//       leftFishes.removeWhere(
//         (fish) => fish.position.dx > screenSize.width + 100 || fish.isHit,
//       );
//       rightFishes.removeWhere((fish) => fish.position.dx < -100 || fish.isHit);
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
//         for (var fish in [...leftFishes, ...rightFishes]) {
//           if (!fish.isHit && (fish.position - missile.position).distance < 30) {
//             _blastFish(fish);
//             missile.position = Offset(-9999, -9999);
//           }
//         }
//       }
//
//       missiles.removeWhere(
//         (m) =>
//             m.position.dy > MediaQuery.of(context).size.height + 30 ||
//             m.position.dy < -30,
//       );
//     });
//   }
//
//   void _blastFish(Fish fish) {
//     fish.isHit = true;
//     coinPosition = fish.position;
//     showCoin = true;
//     aimPoint = null;
//
//     final tween = Tween<Offset>(begin: coinPosition!, end: walletPosition);
//     _flyCoinAnimation = tween.animate(
//       CurvedAnimation(parent: _flyCoinController, curve: Curves.easeInOut),
//     );
//     _flyCoinController.forward(from: 0);
//
//     if (isSoundOn) {
//       _audioPlayer.play(AssetSource('audio/blastsound.mp3'));
//       _coinSoundPlayer.play(AssetSource('audio/coin.mp3'));
//     }
//
//     _walletAnimationController.forward(from: 1.0);
//
//     Future.delayed(Duration(milliseconds: 600), () {
//       setState(() {
//         score++;
//         leftFishes.removeWhere((f) => f.isHit);
//         rightFishes.removeWhere((f) => f.isHit);
//         showCoin = false;
//       });
//     });
//   }
//
//   void _handleFishTap(Offset tapPosition) {
//     for (var fish in [...leftFishes, ...rightFishes]) {
//       if (!fish.isHit && (fish.position - tapPosition).distance < 30) {
//         _blastFish(fish);
//         break;
//       }
//     }
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
//     return atan2(dy, dx);
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
//     _coinSoundPlayer.dispose();
//     _coinController.dispose();
//     _flyCoinController.dispose();
//     _walletAnimationController.dispose();
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
//           final tap = details.localPosition;
//           aimPoint = tap;
//           _fireMissile(tap);
//           _handleFishTap(tap);
//         }
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Image.asset(backgroundUrl, fit: BoxFit.cover),
//             ),
//
//             ...leftFishes.map(
//               (fish) => Positioned(
//                 left: fish.position.dx,
//                 top: fish.position.dy,
//                 child: fish.isHit
//                     ? Image.asset(blastGif, height: 60)
//                     : Image.asset(fish.imageUrl, height: 60),
//               ),
//             ),
//             ...rightFishes.map(
//               (fish) => Positioned(
//                 left: fish.position.dx,
//                 top: fish.position.dy,
//                 child: fish.isHit
//                     ? Image.asset(blastGif, height: 60)
//                     : Image.asset(fish.imageUrl, height: 60),
//               ),
//             ),
//
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
//             if (aimPoint != null && !isPaused)
//               CustomPaint(
//                 painter: AimPainter(from: launcher, to: aimPoint!),
//                 child: Container(),
//               ),
//
//             ...missiles.map(
//               (m) => Positioned(
//                 left: m.position.dx,
//                 top: m.position.dy,
//                 child: Image.asset(missileUrl, height: 30),
//               ),
//             ),
//
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Image.asset(missileUrl, height: 80),
//             ),
//
//             Positioned(
//               top: 10,
//               left: 20,
//               child: ScaleTransition(
//                 scale: _walletAnimationController,
//                 child: Row(
//                   children: [
//                     Image.asset(coinImage, height: 30),
//                     SizedBox(width: 8),
//                     Text(
//                       '$score',
//                       style: TextStyle(
//                         fontSize: 24,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         shadows: [Shadow(blurRadius: 8, color: Colors.black)],
//                       ),
//                     ),
//                   ],
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
//       canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

enum SpawnSide { left, right }

class Fish {
  Offset position;
  String imageUrl;
  double speed;
  bool isHit;
  Offset direction;
  Fish(this.position, this.imageUrl, this.speed,
      {this.isHit = false, required this.direction});
}

class Missile {
  Offset position;
  Offset velocity;

  Missile({required this.position, required this.velocity});

  void update() {
    position += velocity;
  }
}

class SniperScreen extends StatefulWidget {
  const SniperScreen({super.key});

  @override
  State<SniperScreen> createState() => _SniperScreenState();
}

class _SniperScreenState extends State<SniperScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bgMusicPlayer = AudioPlayer();

  List<Fish> leftFishes = [];
  List<Fish> rightFishes = [];
  List<Missile> missiles = [];
  Timer? fishTimer;
  Timer? gameLoop;
  Random random = Random();
  int score = 0;

  int level = 1;
  int scoreToLevelUp = 10;
  DateTime levelStartTime = DateTime.now();
  Duration levelDuration = Duration(seconds: 30);

  bool showLevelPopup = false;
  late ConfettiController _confettiController;

  bool isPaused = false;
  bool isSoundOn = true;
  bool isMusicOn = true;

  Offset? aimPoint;
  Offset? coinPosition;
  bool showCoin = false;
  late AnimationController _coinController;
  late AnimationController _flyCoinController;
  late Animation<Offset> _flyCoinAnimation;

  final walletPosition = Offset(60, 40);

  // LEFT side fish GIFs
  List<String> leftFishUrls = [
    'assets/images/fish11.gif',
    'assets/images/fish12.gif',
    'assets/images/fish12.gif',
  ];

  // RIGHT side fish GIFs
  List<String> rightFishUrls = [
    'assets/images/fish6.gif',
    'assets/images/fish6.gif',
    'assets/images/fish6.gif',
  ];

  String blastGif = 'assets/images/blast.gif';
  String missileUrl = 'assets/images/missile.png';
  String backgroundUrl = 'assets/images/BG.jpg';
  String coinImage = 'assets/images/coins.png';

  @override
  void initState() {
    super.initState();
    _coinController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _flyCoinController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _playBackgroundMusic();
    _startSpawning();
    _startGameLoop();
  }

  void _playBackgroundMusic() async {
    await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
    if (isMusicOn) {
      await _bgMusicPlayer.play(AssetSource('audio/music.mp3'));
    }
  }

  void _startSpawning() {
    fishTimer?.cancel();
    fishTimer = Timer.periodic(
      Duration(milliseconds: (900 - level * 50).clamp(300, 900)),
          (_) {
        if (isPaused) return;
        final screenSize = MediaQuery.of(context).size;

        Offset leftPos = Offset(-60, random.nextDouble() * screenSize.height);
        Offset leftDir = Offset(1, (random.nextDouble() * 2 - 1) * 0.5);
        String leftImage = leftFishUrls[random.nextInt(leftFishUrls.length)];
        double leftSpeed = 1.5 + random.nextDouble() * 2 + (level * 0.3);
        leftFishes.add(Fish(leftPos, leftImage, leftSpeed, direction: leftDir));

        Offset rightPos = Offset(screenSize.width + 60, random.nextDouble() * screenSize.height);
        Offset rightDir = Offset(-1, (random.nextDouble() * 2 - 1) * 0.5);
        String rightImage = rightFishUrls[random.nextInt(rightFishUrls.length)];
        double rightSpeed = 1.5 + random.nextDouble() * 2 + (level * 0.3);
        rightFishes.add(Fish(rightPos, rightImage, rightSpeed, direction: rightDir));

        setState(() {});
      },
    );
  }

  void _startGameLoop() {
    gameLoop = Timer.periodic(Duration(milliseconds: 30), (_) {
      if (isPaused) return;
      _updateFishPositions();
      _updateMissiles();
    });
  }

  void _updateFishPositions() {
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      for (var fish in leftFishes) {
        fish.position += fish.direction * fish.speed;
      }
      for (var fish in rightFishes) {
        fish.position += fish.direction * fish.speed;
      }

      leftFishes.removeWhere((fish) => fish.position.dx > screenSize.width + 100 || fish.isHit);
      rightFishes.removeWhere((fish) => fish.position.dx < -100 || fish.isHit);
    });
  }

  void _updateMissiles() {
    setState(() {
      for (var missile in missiles) {
        missile.update();
      }

      for (var missile in missiles) {
        for (var fish in [...leftFishes, ...rightFishes]) {
          if (!fish.isHit && (fish.position - missile.position).distance < 30) {
            _blastFish(fish);
            missile.position = Offset(-9999, -9999);
          }
        }
      }

      missiles.removeWhere((m) =>
      m.position.dy > MediaQuery.of(context).size.height + 30 ||
          m.position.dy < -30);
    });
  }

  void _blastFish(Fish fish) {
    fish.isHit = true;
    coinPosition = fish.position;
    showCoin = true;
    aimPoint = null;

    final tween = Tween<Offset>(begin: coinPosition!, end: walletPosition);
    _flyCoinAnimation = tween.animate(CurvedAnimation(parent: _flyCoinController, curve: Curves.easeInOut));
    _flyCoinController.forward(from: 0);

    if (isSoundOn) {
      _audioPlayer.play(AssetSource('audio/blastsound.mp3'));
    }

    score++;

    bool shouldLevelUp = false;
    if (score % scoreToLevelUp == 0) shouldLevelUp = true;
    if (DateTime.now().difference(levelStartTime) > levelDuration) shouldLevelUp = true;

    if (shouldLevelUp) {
      level++;
      levelStartTime = DateTime.now();
      _showLevelUpPopup();
      _startSpawning();
    }

    Future.delayed(Duration(milliseconds: 600), () {
      setState(() {
        leftFishes.removeWhere((f) => f.isHit);
        rightFishes.removeWhere((f) => f.isHit);
        showCoin = false;
      });
    });
  }

  void _showLevelUpPopup() {
    _confettiController.play();
    setState(() => showLevelPopup = true);
    Future.delayed(Duration(seconds: 2), () {
      setState(() => showLevelPopup = false);
    });
  }

  void _handleFishTap(Offset tapPosition) {
    for (var fish in [...leftFishes, ...rightFishes]) {
      if (!fish.isHit && (fish.position - tapPosition).distance < 30) {
        _blastFish(fish);
        break;
      }
    }
  }

  void _fireMissile(Offset target) {
    final start = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height - 40,
    );

    final dx = target.dx - start.dx;
    final dy = target.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final velocity = Offset(dx / distance * 6, dy / distance * 6);

    setState(() {
      missiles.add(Missile(position: start, velocity: velocity));
    });
  }

  double getAngle(Offset from, Offset to) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    return atan2(dy, dx);
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  void dispose() {
    fishTimer?.cancel();
    gameLoop?.cancel();
    _audioPlayer.dispose();
    _bgMusicPlayer.dispose();
    _coinController.dispose();
    _flyCoinController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final launcher = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height - 40,
    );

    return GestureDetector(
      onPanUpdate: (details) {
        if (!isPaused) {
          setState(() {
            aimPoint = details.localPosition;
          });
        }
      },
      onTapDown: (details) {
        if (!isPaused) {
          final tap = details.localPosition;
          aimPoint = tap;
          _fireMissile(tap);
          _handleFishTap(tap);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(backgroundUrl, fit: BoxFit.cover),
            ),

            ...leftFishes.map((fish) => Positioned(
              left: fish.position.dx,
              top: fish.position.dy,
              child: fish.isHit
                  ? Image.asset(blastGif, height: 60)
                  : Image.asset(fish.imageUrl, height: 60),
            )),
            ...rightFishes.map((fish) => Positioned(
              left: fish.position.dx,
              top: fish.position.dy,
              child: fish.isHit
                  ? Image.asset(blastGif, height: 60)
                  : Image.asset(fish.imageUrl, height: 60),
            )),

            if (showCoin && coinPosition != null)
              AnimatedBuilder(
                animation: _flyCoinAnimation,
                builder: (context, child) {
                  final position = _flyCoinAnimation.value;
                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: Image.asset(coinImage, height: 30),
                  );
                },
              ),

            if (aimPoint != null && !isPaused)
              CustomPaint(
                painter: AimPainter(from: launcher, to: aimPoint!),
                child: Container(),
              ),

            // ...missiles.map((m) => Positioned(
            //   left: m.position.dx,
            //   top: m.position.dy,
            //   child: Image.asset(missileUrl, height: 30),
            // )),

            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                missileUrl,
                height: 100,
              ),
            ),

            Positioned(
              top: 30,
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

            Positioned(
              top: 30,
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

            if (showLevelPopup)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: [Colors.yellow, Colors.green, Colors.pink, Colors.blue],
                    ),
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🎉 Congratulations!',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          Text(
                            'Level $level Unlocked',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            Positioned(
              top: 30,
              right: 20,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                    ),
                    onPressed: _togglePause,
                  ),
                  IconButton(
                    icon: Icon(
                      isMusicOn ? Icons.music_note : Icons.music_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => isMusicOn = !isMusicOn);
                      isMusicOn
                          ? _playBackgroundMusic()
                          : _bgMusicPlayer.stop();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isSoundOn ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => isSoundOn = !isSoundOn);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _bgMusicPlayer.stop();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AimPainter extends CustomPainter {
  final Offset from;
  final Offset to;

  AimPainter({required this.from, required this.to});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 6;
    const dashSpace = 6;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final steps = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < steps; i++) {
      final startX = from.dx + (i * (dashWidth + dashSpace)) * dx / distance;
      final startY = from.dy + (i * (dashWidth + dashSpace)) * dy / distance;
      final endX = startX + (dashWidth * dx / distance);
      final endY = startY + (dashWidth * dy / distance);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
