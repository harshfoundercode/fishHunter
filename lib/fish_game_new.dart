import 'dart:async';
import 'dart:math';
import 'package:fish_game/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Fish {
  Offset position;
  String imageUrl;
  double speed;
  bool isHit;
  Offset direction;
  double size;
  int value; // Coin value of the fish

  Fish({
    required this.position,
    required this.imageUrl,
    required this.speed,
    required this.direction,
    this.isHit = false,
    this.size = 80.0,
    this.value = 10, // Default coin value
  });
}

class Coin {
  Offset position;
  double size;
  int value;
  double opacity;
  double verticalSpeed;

  Coin({
    required this.position,
    required this.value,
    this.size = 30.0,
    this.opacity = 1.0,
    this.verticalSpeed = -2.0,
  });

  void update() {
    position += Offset(0, verticalSpeed);
    verticalSpeed += 0.1; // Gravity effect
    opacity -= 0.02; // Fade out
  }
}

class FishGameScreenNew extends StatefulWidget {
  final int level;
  const FishGameScreenNew({super.key, required this.level});

  @override
  State<FishGameScreenNew> createState() => _FishGameScreenNewState();
}

class _FishGameScreenNewState extends State<FishGameScreenNew> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Random _random = Random();
  List<Fish> fishes = [];
  List<Coin> coins = [];
  Timer? _fishTimer;
  Timer? _gameLoop;
  int score = 0;
  int wallet = 0; // Added wallet to store coins
  bool isPaused = false;
  bool isSoundOn = true;
  bool isMusicOn = true;
  Offset? aimPoint;

  // Asset paths
  final List<String> fishUrls = [
    'assets/images/fish1.png',
    'assets/images/fish2.png',
    'assets/images/fish3.png',
    'assets/images/fish4.png',
    'assets/images/fish5.png',
    'assets/images/fish6.gif',
    'assets/images/fish1.png',
    'assets/images/fish2.png',
    'assets/images/fish3.png',
    'assets/images/fish4.png',
    'assets/images/fish5.png',
    'assets/images/fish6.gif',
    'assets/images/fish1.png',
    'assets/images/fish2.png',
    'assets/images/fish3.png',
    'assets/images/fish4.png',
    'assets/images/fish5.png',
    'assets/images/fish6.gif',
    'assets/images/fish1.png',
    'assets/images/fish2.png',
    'assets/images/fish3.png',
    'assets/images/fish4.png',
    'assets/images/fish5.png',
    'assets/images/fish6.gif',
  ];
  final String bulletImage = 'assets/images/missile.png';
  final String blastGif = 'assets/images/blast.gif';
  final String coinImage = 'assets/images/coins.png'; // Add coin image
  final String backgroundImage = 'assets/images/bg3.png';

  @override
  void initState() {
    super.initState();
    _startSpawning();
    _startGameLoop();
    _playMusic();
  }

  void _playMusic() async {
    if (isMusicOn) {
      await _musicPlayer.play(AssetSource('audio/music.mp3'));
      _musicPlayer.setReleaseMode(ReleaseMode.loop);
    }
  }

  void _startSpawning() {
    _fishTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (isPaused) return;
      _spawnFish();
    });
  }

  void _spawnFish() {
    final screenSize = MediaQuery.of(context).size;
    final spawnEdge = _random.nextInt(4);

    Offset position;
    Offset direction;

    switch (spawnEdge) {
      case 0: // Left
        position = Offset(-80, _random.nextDouble() * screenSize.height);
        direction = Offset(1, _random.nextDouble() * 0.6 - 0.3);
        break;
      case 1: // Right
        position = Offset(
          screenSize.width + 80,
          _random.nextDouble() * screenSize.height,
        );
        direction = Offset(-1, _random.nextDouble() * 0.6 - 0.3);
        break;
      case 2: // Top
        position = Offset(_random.nextDouble() * screenSize.width, -80);
        direction = Offset(_random.nextDouble() * 0.6 - 0.3, 1);
        break;
      case 3: // Bottom
        position = Offset(
          _random.nextDouble() * screenSize.width,
          screenSize.height + 80,
        );
        direction = Offset(_random.nextDouble() * 0.6 - 0.3, -1);
        break;
      default:
        position = Offset.zero;
        direction = Offset(1, 0);
    }

    setState(() {
      fishes.add(
        Fish(
          position: position,
          imageUrl: fishUrls[_random.nextInt(fishUrls.length)],
          speed: 1.0 + _random.nextDouble() * 2.0,
          direction: direction,
          size: 60.0 + _random.nextDouble() * 60.0,
          value: 5 + _random.nextInt(20), // Random coin value between 5-25
        ),
      );
    });
  }

  void _startGameLoop() {
    _gameLoop = Timer.periodic(Duration(milliseconds: 16), (_) {
      if (isPaused) return;
      _updateFishPositions();
      _updateCoins();
    });
  }

  void _updateFishPositions() {
    setState(() {
      for (var fish in fishes) {
        fish.position += fish.direction * fish.speed;
      }

      fishes.removeWhere(
        (fish) =>
            fish.position.dx < -100 ||
            fish.position.dx > MediaQuery.of(context).size.width + 100 ||
            fish.position.dy < -100 ||
            fish.position.dy > MediaQuery.of(context).size.height + 100 ||
            fish.isHit,
      );
    });
  }

  void _updateCoins() {
    setState(() {
      for (var coin in coins) {
        coin.update();
        if (coin.opacity <= 0) {
          wallet += coin.value;
        }
      }
      coins.removeWhere((coin) => coin.opacity <= 0);
    });
  }

  void _hitFish(Fish fish) {
    setState(() {
      fish.isHit = true;
      score++;

      // Add coin animation
      coins.add(
        Coin(position: fish.position, value: fish.value, size: fish.size / 2),
      );

      if (isSoundOn) _playSound('blastsound');

      // Remove fish after delay
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          fishes.removeWhere((f) => f.isHit);
        });
      });
    });
  }

  void _handleTap(Offset tapPosition) {
    if (isPaused) return;

    // Check if tapped on any fish
    for (var fish in fishes) {
      if ((tapPosition - fish.position).distance < fish.size / 2) {
        _hitFish(fish);
        return;
      }
    }
  }

  void _playSound(String sound) async {
    await _audioPlayer.play(AssetSource('audio/$sound.mp3'));
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        _musicPlayer.pause();
      } else {
        if (isMusicOn) _musicPlayer.resume();
      }
    });
  }

  void _toggleSound() {
    setState(() {
      isSoundOn = !isSoundOn;
    });
  }

  void _toggleMusic() {
    setState(() {
      isMusicOn = !isMusicOn;
      if (isMusicOn) {
        _playMusic();
      } else {
        _musicPlayer.pause();
      }
    });
  }

  void _exitGame() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _fishTimer?.cancel();
    _gameLoop?.cancel();
    _audioPlayer.dispose();
    _musicPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final launcherPos = Offset(screenSize.width / 2, screenSize.height - 40);

    return GestureDetector(
      onTapDown: (details) => _handleTap(details.localPosition),
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(backgroundImage, fit: BoxFit.cover),
            ),

            // Fishes
            ...fishes.map(
              (fish) => Positioned(
                left: fish.position.dx - fish.size / 2,
                top: fish.position.dy - fish.size / 2,
                child: fish.isHit
                    ? Image.asset(blastGif, width: fish.size * 1.5)
                    : Image.asset(fish.imageUrl, width: fish.size),
              ),
            ),

            // Coins
            ...coins.map(
              (coin) => Positioned(
                left: coin.position.dx - coin.size / 2,
                top: coin.position.dy - coin.size / 2,
                child: Opacity(
                  opacity: coin.opacity,
                  child: Column(
                    children: [
                      Image.asset(coinImage, width: coin.size),
                      Text(
                        '+${coin.value}',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 40,
              right: 40,
              bottom: 1,
              child: Image.asset(
                Assets.imagesMissile,
                height: screenSize.height * 0.2,
              ),
            ),
            // Score and Wallet
            Positioned(
              top: 40,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score: ${score}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Coins: $wallet',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                    ),
                  ),
                ],
              ),
            ),

            // Control buttons
            Positioned(
              top: 40,
              right: 20,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isSoundOn ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleSound,
                  ),
                  IconButton(
                    icon: Icon(
                      isMusicOn ? Icons.music_note : Icons.music_off,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleMusic,
                  ),
                  IconButton(
                    icon: Icon(
                      isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _togglePause,
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
}
