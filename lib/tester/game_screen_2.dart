// import 'dart:math';
// import 'dart:async';
// import 'package:fish_game/model/coin_animation.dart';
// import 'package:fish_game/model/net_model.dart';
// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:confetti/confetti.dart';
//
// import '../model/fish_model.dart' show Fish;
// import '../model/missile_model.dart' show Missile;
//
// class SniperGame2 extends StatefulWidget {
//   const SniperGame2({super.key});
//
//   @override
//   State<SniperGame2> createState() => _SniperGame2State();
// }
//
// class _SniperGame2State extends State<SniperGame2> with TickerProviderStateMixin {
//   List<Fish> leftFishes = [];
//   List<Fish> rightFishes = [];
//   List<Missile> missiles = [];
//   List<Net> nets = [];
//   List<CoinAnimation> coinAnimations = [];
//
//   // Game Control
//   Timer? fishTimer;
//   Timer? gameLoop;
//   Random random = Random();
//   int score = 0;
//   int timeLeft = 60;
//   int level = 1;
//   int requiredScore = 60;
//
//   // Audio
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final AudioPlayer _bgMusicPlayer = AudioPlayer();
//   bool isSoundOn = true;
//   bool isMusicOn = true;
//   bool isPaused = false;
//
//   bool isMagnetActive = false;
//   bool magnetAvailable = false;
//
//   // UI States
//   Offset? aimPoint;
//   Offset? missileTarget;
//   final walletPosition = Offset(7, 7);
//   late ConfettiController _confettiController;
//
//   // Assets
//   List<String> leftFishUrls = ['assets/images/fish13.gif', 'assets/images/fish14.gif'];
//   List<String> rightFishUrls = ['assets/images/fish15.gif','assets/images/fish16.gif'];
//   String blastGif = 'assets/images/blast.gif';
//   String missileUrl = 'assets/images/missile.png';
//   String backgroundUrl = 'assets/images/bg5.gif';
//   String coinImage = 'assets/images/coins.png';
//   String netImage = 'assets/images/net.png';
//   String blastSound = 'audio/net_active.ogg';
//   String netSound = 'audio/net_active.ogg';
//   String coinSound = 'audio/coin.mp3';
//   String bgMusic = 'audio/music.mp3';
//
//   @override
//   void initState() {
//     super.initState();
//     _confettiController = ConfettiController(duration: Duration(seconds: 2));
//     // _playBackgroundMusic();
//     _startSpawning();
//     _startGameLoop();
//     _startLevelTimer();
//   }
//
//   void _startLevelTimer() {
//     timeLeft = 60;
//     Timer.periodic(Duration(seconds: 1), (timer) {
//       if (!mounted) return;
//       setState(() => timeLeft--);
//       if (timeLeft <= 0) {
//         timer.cancel();
//         _checkLevelCompletion();
//       }
//     });
//   }
//
//   void _playBackgroundMusic() async {
//     await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
//     if (isMusicOn) await _bgMusicPlayer.play(AssetSource(bgMusic));
//   }
//
//   void _startSpawning() {
//     fishTimer = Timer.periodic(
//       Duration(milliseconds: (800 - level * 50).clamp(600, 1500)),
//           (_) {
//         if (!mounted || isPaused) return;
//         final screenSize = MediaQuery.of(context).size;
//
//         // Only spawn fish 50% of the time to reduce quantity
//         if (random.nextDouble() > 0.5) {
//           leftFishes.add(Fish(
//             Offset(-60, random.nextDouble() * screenSize.height),
//             leftFishUrls[random.nextInt(leftFishUrls.length)],
//             1.0 + random.nextDouble() * 1.5 + (level * 0.2), // Slower speed
//             direction: Offset(0.8, (random.nextDouble() * 2 - 1) * 0.3), // Gentler movement
//           ));
//           }
//
//          // Only spawn fish 50% of the time to reduce quantity
//               if (random.nextDouble() > 0.5) {
//             rightFishes.add(Fish(
//             Offset(screenSize.width + 60, random.nextDouble() * screenSize.height),
//             rightFishUrls[random.nextInt(rightFishUrls.length)],
//             1.0 + random.nextDouble() * 1.5 + (level * 0.2), // Slower speed
//             direction: Offset(-0.8, (random.nextDouble() * 2 - 1) * 0.3), // Gentler movement
//             ));
//             }
//
//         if (mounted) setState(() {});
//       },
//     );
//   }
//
//   void _startGameLoop() {
//     gameLoop = Timer.periodic(Duration(milliseconds: 30), (_) {
//       if (!mounted || isPaused) return;
//       _updateFishPositions();
//       _updateMissiles();
//       _updateNets();
//       _updateCoinAnimations();
//     });
//   }
//
//   void _updateFishPositions() {
//     final screenSize = MediaQuery.of(context).size;
//
//     setState(() {
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
//   void _updateCoinAnimations() {
//     coinAnimations.removeWhere((anim) => !anim.controller.isAnimating);
//     if (mounted) setState(() {});
//
//     if (score >= 20 && !magnetAvailable) {
//       magnetAvailable = true;
//       setState(() {});
//     }
//   }
//
//   void _showSparkleAt(Offset position) {
//     final overlayEntry = OverlayEntry(
//       builder: (context) {
//         return Positioned(
//           left: position.dx - 20,
//           top: position.dy - 20,
//           child: Image.asset(
//             'assets/images/sparkle.gif', // or use burst GIF
//             height: 50,
//             width: 50,
//           ),
//         );
//       },
//     );
//
//     Overlay.of(context)?.insert(overlayEntry);
//     Future.delayed(Duration(milliseconds: 500), () => overlayEntry.remove());
//   }
//
//
//   double getCoinSizeFromFish(String fishImageUrl) {
//     if (fishImageUrl.contains("fish13")) return 28.0;
//     if (fishImageUrl.contains("fish14")) return 36.0;
//     if (fishImageUrl.contains("fish15")) return 32.0;
//     return 30.0;
//   }
//
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
//           _showSparkleAt(fish.position);
//         }
//       });
//
//       // Create coin animations for each fish
//       for (int i = 0; i < net.caughtFishes.length; i++) {
//         final fish = net.caughtFishes[i];
//         final controller = AnimationController(
//           vsync: this,
//           duration: Duration(milliseconds: 1500 + random.nextInt(500)),
//         );
//
// // Movement animation (fish to wallet)
//         final animation = Tween<Offset>(
//           begin: fish.position,
//           end: walletPosition,
//         ).animate(CurvedAnimation(
//           parent: controller,
//           curve: Curves.easeInOutBack,
//         ));
//
// // Add rotation animation
//         final rotation = Tween<double>(
//           begin: 0.0,
//           end: 2 * pi,
//         ).animate(CurvedAnimation(
//           parent: controller,
//           curve: Curves.linear,
//         ));
//
// // Add scaling animation (pulsating size)
//         final scale = Tween<double>(
//           begin: 0.8,
//           end: 1.2,
//         ).animate(CurvedAnimation(
//           parent: controller,
//           curve: Curves.easeInOut,
//         ));
//
//         final coinAnim = CoinAnimation(
//           controller: controller,
//           animation: animation,
//           rotation: rotation,
//           scale: scale,
//           start: fish.position,
//         );
//
//
//         setState(() {
//           coinAnimations.add(coinAnim);
//         });
//
//         // Play coin sound for each fish with slight delay
//         if (isSoundOn) {
//           Future.delayed(Duration(milliseconds: i * 150), () {
//             _audioPlayer.play(AssetSource(coinSound));
//           });
//         }
//
//         controller.forward().whenComplete(() {
//           if (mounted) {
//             setState(() {
//               coinAnimations.remove(coinAnim);
//             });
//           }
//           controller.dispose();
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
//       if (mounted) setState(() => nets.remove(net));
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
//   void _activateMagnet() {
//     setState(() {
//       isMagnetActive = true;
//       magnetAvailable = false;
//     });
//
//     final screenCenter = Offset(
//       MediaQuery.of(context).size.width / 2,
//       MediaQuery.of(context).size.height / 2,
//     );
//
//     // Select 10–15 closest fish
//     List<Fish> allFishes = [...leftFishes, ...rightFishes];
//     allFishes.removeWhere((f) => f.isHit || f.isInNet);
//     allFishes.sort((a, b) => (a.position - screenCenter).distance.compareTo((b.position - screenCenter).distance));
//
//     List<Fish> attractedFishes = allFishes.take(15).toList();
//
//     // for (var fish in attractedFishes) {
//     //   // Create coin animation from fish to wallet
//     //   final controller = AnimationController(
//     //     vsync: this,
//     //     duration: Duration(milliseconds: 1000),
//     //   );
//     //
//     //   final animation = Tween<Offset>(
//     //     begin: fish.position,
//     //     end: walletPosition,
//     //   ).animate(CurvedAnimation(
//     //     parent: controller,
//     //     curve: Curves.easeOut,
//     //   ));
//     //
//     //   final coinAnim = CoinAnimation(
//     //     controller: controller,
//     //     animation: animation,
//     //     position: fish.position,
//     //   );
//     //
//     //   setState(() {
//     //     coinAnimations.add(coinAnim);
//     //   });
//     //
//     //   controller.forward().whenComplete(() {
//     //     if (mounted) {
//     //       setState(() {
//     //         coinAnimations.remove(coinAnim);
//     //       });
//     //     }
//     //     controller.dispose();
//     //   });
//     //
//     //   // Optional: Play coin sound with slight delay
//     //   if (isSoundOn) {
//     //     Future.delayed(Duration(milliseconds: 100), () {
//     //       _audioPlayer.play(AssetSource(coinSound));
//     //     });
//     //   }
//     //
//     //   fish.isHit = true;
//     // }
//
//     for (var fish in attractedFishes) {
//       final controller = AnimationController(
//         vsync: this,
//         duration: Duration(milliseconds: 1500 + random.nextInt(500)),
//       );
//
//       final animation = Tween<Offset>(
//         begin: fish.position,
//         end: walletPosition,
//       ).animate(CurvedAnimation(
//         parent: controller,
//         curve: Curves.easeOutBack,
//       ));
//
//       final rotation = Tween<double>(
//         begin: 0,
//         end: 2 * pi,
//       ).animate(CurvedAnimation(
//         parent: controller,
//         curve: Curves.linear,
//       ));
//
//       final scale = Tween<double>(
//         begin: 0.8,
//         end: 1.2,
//       ).animate(CurvedAnimation(
//         parent: controller,
//         curve: Curves.easeInOut,
//       ));
//
//       final coinAnim = CoinAnimation(
//         controller: controller,
//         animation: animation,
//         rotation: rotation,
//         scale: scale,
//         start: fish.position,
//       );
//
//       setState(() {
//         coinAnimations.add(coinAnim);
//       });
//
//       controller.forward().whenComplete(() {
//         if (mounted) {
//           setState(() {
//             coinAnimations.remove(coinAnim);
//           });
//         }
//         controller.dispose();
//       });
//
//       if (isSoundOn) {
//         Future.delayed(Duration(milliseconds: 100), () {
//           _audioPlayer.play(AssetSource(coinSound));
//         });
//       }
//
//       fish.isHit = true;
//     }
//
//
//     leftFishes.removeWhere((f) => attractedFishes.contains(f));
//     rightFishes.removeWhere((f) => attractedFishes.contains(f));
//
//     // Add score for attracted fishes
//     setState(() {
//       score += attractedFishes.length;
//     });
//
//     // Reset magnet after delay
//     Timer(Duration(seconds: 1), () {
//       if (mounted) setState(() => isMagnetActive = false);
//     });
//   }
//
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
//           if (!isPaused) setState(() => aimPoint = details.localPosition);
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
//               child: Image.asset(backgroundUrl, fit: BoxFit.cover),
//             ),
//
//             // Fish
//             ...leftFishes.map((fish) => Positioned(
//               left: fish.position.dx,
//               top: fish.position.dy,
//               child: fish.isHit
//                   ? Image.asset(blastGif, height: 50)
//                   : fish.isInNet
//                   ? ColorFiltered(
//                 colorFilter: ColorFilter.mode(
//                   Colors.blue.withOpacity(0.7),
//                   BlendMode.srcATop,
//                 ),
//                 child: Image.asset(fish.imageUrl, height: 50),
//               )
//                   : Image.asset(fish.imageUrl, height: 50),
//             )),
//
//             ...rightFishes.map((fish) => Positioned(
//               left: fish.position.dx,
//               top: fish.position.dy,
//               child: fish.isHit
//                   ? Image.asset(blastGif, height: 50)
//                   : fish.isInNet
//                   ? ColorFiltered(
//                 colorFilter: ColorFilter.mode(
//                   Colors.blue.withOpacity(0.7),
//                   BlendMode.srcATop,
//                 ),
//                 child: Image.asset(fish.imageUrl, height: 50),
//               )
//                   : Image.asset(fish.imageUrl, height: 50),
//             )),
//
//             // Nets
//             ...nets.map((net) => Positioned(
//               left: net.center.dx - net.radius,
//               top: net.center.dy - net.radius,
//               child: Image.asset(
//                 netImage,
//                 width: net.radius * 2,
//                 height: net.radius * 2,
//               ),
//             )),
//
//             // Missiles
//             ...missiles.map((missile) => Positioned(
//               left: missile.position.dx,
//               top: missile.position.dy,
//               child: Transform.rotate(
//                 angle: atan2(missile.velocity.dy, missile.velocity.dx) + pi/2,
//                 child: Image.asset(coinImage, height: 40),
//               ),
//             )),
//
//             // Coin Animations
//             ...coinAnimations.map((anim) => AnimatedBuilder(
//               animation: anim.controller,
//               builder: (context, child) {
//                 return Positioned(
//                   left: anim.animation.value.dx,
//                   top: anim.animation.value.dy,
//                   child: Transform.rotate(
//                     angle: anim.rotation.value,
//                     child: Transform.scale(
//                       scale: anim.scale.value,
//                       child: Image.asset(
//                         coinImage,
//                         height: 35,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             )),
//
//
//
//
//             // // Aim Line
//             // if (aimPoint != null)
//             //   CustomPaint(
//             //     painter: _AimPainter(from: launcher, to: aimPoint!),
//             //     child: Container(),
//             //   ),
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
//
//             // Score Display
//             Positioned(
//               top: 1,
//               left: 20,
//               child: Container(
//                 height: 40,
//                 width: 80,
//                 decoration: BoxDecoration(
//                     image: DecorationImage(image: AssetImage("assets/images/score.png"),fit: BoxFit.fill)
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Image.asset(coinImage, height: 30),
//                     Text(
//                       '$score',
//                       style: TextStyle(
//                         fontSize: 20,
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
//             // Level Display
//             Positioned(
//               top: 1,
//               left: 150,
//               child: Container(
//                  height: 40,
//                  width: 125,
//                  margin: EdgeInsets.symmetric(horizontal: 10),
//                decoration: BoxDecoration(
//                     image: DecorationImage(image: AssetImage("assets/images/level.png"),fit: BoxFit.fill)
//                  ),
//                 child: Center(
//                   child: Text(
//                     'Level: $level',
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       shadows: [Shadow(blurRadius: 8, color: Colors.black)],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Timer Display
//             Positioned(
//               top: 6,
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
//             // Magnet Button
//             if (magnetAvailable && !isMagnetActive)
//               Positioned(
//                 bottom: 100,
//                 right: 20,
//                 child: GestureDetector(
//                   onTap: _activateMagnet,
//                   child: Container(
//                     height: 60,
//                     width: 60,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.orangeAccent,
//                       boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
//                     ),
//                     child: Center(
//                       child: Icon(Icons.star_rate, size: 30, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//
//             // Control Buttons
//             Positioned(
//               top: 1,
//               right: 20,
//               child: Row(
//                 children: [
//                   InkWell(
//                     onTap:(){
//                       _toggleSound(context);
//                       print("fcbjhrgvuicf");
//                      },
//                     child: Container(
//                       height: 40,
//                       width: 40,
//                       margin: EdgeInsets.symmetric(horizontal: 10),
//                       decoration: BoxDecoration(
//                         image: DecorationImage(image: AssetImage(isSoundOn ?"assets/images/volumeon.png":"assets/images/volumeof.png"),fit: BoxFit.fill)
//                       ),
//                     ),
//                   ),
//                   InkWell(
//                     onTap:(){
//                       _toggleMusic(context);
//                       print("wdugwigdw");
//                     },
//                     child: Container(
//                       height: 40,
//                       width: 40,
//                       margin: EdgeInsets.symmetric(horizontal: 10),
//                       decoration: BoxDecoration(
//                           image: DecorationImage(image: AssetImage(isMusicOn ?"assets/images/musicon.png":"assets/images/musicoff.png"),fit: BoxFit.fill)
//                       ),
//                     ),
//                   ),
//                   InkWell(
//                     onTap: _exitGame,
//                     child: Container(
//                       height: 40,
//                       width: 40,
//                       margin: EdgeInsets.symmetric(horizontal: 10),
//                       decoration: BoxDecoration(
//                           image: DecorationImage(image: AssetImage("assets/images/menu.png"),fit: BoxFit.fill)
//                       ),
//                     ),
//                   ),
//                   // IconButton(
//                   //   icon: Icon(
//                   //     isSoundOn ? Icons.volume_up : Icons.volume_off,
//                   //     color: Colors.white,
//                   //     size: 30,
//                   //   ),
//                   //   onPressed:(){
//                   //     _toggleSound(context);
//                   //     print("fcbjhrgvuicf");
//                   //   } ,
//                   // ),
//                   // IconButton(
//                   //   icon: Icon(
//                   //     isMusicOn ? Icons.music_note : Icons.music_off,
//                   //     color: Colors.white,
//                   //     size: 30,
//                   //   ),
//                   //   onPressed: (){
//                   //     _toggleMusic(context);
//                   //     print("wdugwigdw");
//                   //   },
//                   // ),
//                   // IconButton(
//                   //   icon: Icon(
//                   //     isPaused ? Icons.play_arrow : Icons.pause,
//                   //     color: Colors.white,
//                   //     size: 30,
//                   //   ),
//                   //   onPressed:(){
//                   //     _togglePause(context);
//                   //   } ,
//                   // ),
//                   // IconButton(
//                   //   icon: Icon(
//                   //     Icons.exit_to_app,
//                   //     color: Colors.white,
//                   //     size: 30,
//                   //   ),
//                   //   onPressed: _exitGame,
//                   // ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   void _togglePause(context) {
//     setState(() {
//       isPaused = !isPaused;
//       if (isPaused) {
//         _bgMusicPlayer.pause();
//         fishTimer?.cancel();
//         gameLoop?.cancel();
//
//       } else {
//         if (isMusicOn) _bgMusicPlayer.resume();
//         _startSpawning();
//         _startGameLoop();
//       }
//     });
//   }
//
//   void _toggleSound(context) => setState(() => isSoundOn = !isSoundOn);
//
//
//   Future<void> _toggleMusic(context) async {
//     setState(() {
//       isMusicOn = !isMusicOn;
//     });
//
//     if (isMusicOn) {
//       await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
//       await _bgMusicPlayer.play(AssetSource(bgMusic));
//     } else {
//       // await _bgMusicPlayer.pause();
//       // Alternatively, you could use stop() for complete reset
//       await _bgMusicPlayer.stop();
//     }
//   }
//
//   void _exitGame() => Navigator.of(context).pop();
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
//         backgroundColor: Color(0xff59aebb),
//         title: Text('💀 Game Over',style: TextStyle(color: Colors.white),),
//         content: Text('You didn\'t reach the required score.',style: TextStyle(color: Colors.white),),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
//             child: Text('Exit',style: TextStyle(color: Colors.white),),
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
//             child: Text('Retry',style: TextStyle(color: Colors.white),),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     fishTimer?.cancel();
//     gameLoop?.cancel();
//     _audioPlayer.dispose();
//     _bgMusicPlayer.dispose();
//     for (var anim in coinAnimations) {
//       anim.controller.dispose();
//     }
//     _confettiController.dispose();
//     super.dispose();
//   }
// }
//
