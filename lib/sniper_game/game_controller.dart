import 'dart:async';
import 'dart:math';
import 'package:fish_game/sniper_game/components/coin_animation_widget.dart'
    show CoinAnimationWidget;
import 'package:fish_game/sniper_game/components/fish_widget.dart';
import 'package:fish_game/sniper_game/components/missile_widget.dart'
    show MissileWidget;
import 'package:fish_game/sniper_game/helper/audio_helper.dart';
import 'package:fish_game/sniper_game/model/coin_animation.dart';
import 'package:fish_game/sniper_game/model/fish_model.dart' show Fish;
import 'package:fish_game/sniper_game/model/missile_model.dart' show Missile;
import 'package:fish_game/sniper_game/model/net_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class GameController {
  final BuildContext context;
  final TickerProvider ticker;
  late double walletX, walletY;

  GameController(this.context, this.ticker, int startLevel);

  // Assets
  final leftFishUrls = ['assets/images/fish13.gif', 'assets/images/fish14.gif'];
  final rightFishUrls = ['assets/images/fish15.gif', 'assets/images/fish16.gif',];
  final blastGif = 'assets/images/blast.gif';
  final missileAsset = 'assets/images/missile.png';
  final coinAsset = 'assets/images/coins.png';
  final bgAsset = 'assets/images/bg4.gif';
  final netAsset = 'assets/images/net.png';
  final soundNet = 'audio/net_active.ogg';
  final soundCoin = 'audio/coin.mp3';
  final musicAsset = 'audio/music.mp3';

  // State
  final List<Fish> leftFishes = [];
  final List<Fish> rightFishes = [];
  final List<Missile> missiles = [];
  final List<Net> nets = [];
  final List<CoinAnimation> coinAnimations = [];
  int score = 0, level = 1, requiredScore = 0, timeLeft = 0;
  bool isPaused = false,
      isSoundOn = true,
      isMusicOn = true,
      magnetAvailable = false,
      isMagnetActive = false;
  Offset? missileTarget;
  final random = Random();
  Timer? fishTimer, loopTimer, levelTimer;
  final audio = AudioHelper();

  // Level configs
  // final List<Map<String, dynamic>> levelConfigs = [
  //   {'score': 10, 'time': 30, 'fishTarget': {}},
  //   {
  //     'score': 20,
  //     'time': 35,
  //     'fishTarget': {'fish14.gif': 5},
  //   },
  //   {
  //     'score': 30,
  //     'time': 40,
  //     'fishTarget': {'fish13.gif': 2, 'fish15.gif': 3},
  //   },
  //   {
  //     'score': 40,
  //     'time': 45,
  //     'fishTarget': {'fish16.gif': 4},
  //   },
  //   {
  //     'score': 50,
  //     'time': 50,
  //     'fishTarget': {'fish13.gif': 3, 'fish14.gif': 3},
  //   },
  //   {
  //     'score': 60,
  //     'time': 55,
  //     'fishTarget': {'fish15.gif': 5},
  //   },
  //   {
  //     'score': 70,
  //     'time': 60,
  //     'fishTarget': {'fish16.gif': 6},
  //   },
  //   {
  //     'score': 80,
  //     'time': 65,
  //     'fishTarget': {'fish13.gif': 4, 'fish14.gif': 4},
  //   },
  //   {
  //     'score': 90,
  //     'time': 70,
  //     'fishTarget': {'fish15.gif': 6},
  //   },
  //   {
  //     'score': 100,
  //     'time': 75,
  //     'fishTarget': {'fish16.gif': 7},
  //   },
  // ];

  static final List<Map<String, dynamic>> levelConfigs = [
    {'score': 10, 'time': 30, 'fishTarget': {}},
    {'score': 20, 'time': 35, 'fishTarget': {'fish14.gif': 5}},
    {'score': 30, 'time': 40, 'fishTarget': {'fish13.gif': 2, 'fish15.gif': 3}},
    {'score': 40, 'time': 45, 'fishTarget': {'fish16.gif': 4}},
    {'score': 50, 'time': 50, 'fishTarget': {'fish13.gif': 3, 'fish14.gif': 3}},
    {'score': 60, 'time': 55, 'fishTarget': {'fish15.gif': 5}},
    {'score': 70, 'time': 60, 'fishTarget': {'fish16.gif': 6}},
    {'score': 80, 'time': 65, 'fishTarget': {'fish13.gif': 4, 'fish14.gif': 4}},
    {'score': 90, 'time': 70, 'fishTarget': {'fish15.gif': 6}},
    {'score': 100, 'time': 75, 'fishTarget': {'fish16.gif': 7}},
  ];


  Map<String, int> fishCollected = {};
  Map<String, int> currentFishTarget = {};

  void init() {
    walletX = 7;
    walletY = 7;
    _loadLevelConfig();
    if (isMusicOn) audio.playBackgroundMusic(musicAsset);
    _startSpawning();
    _startLoop();
    _startLevelTimer();
  }

  void dispose() {
    fishTimer?.cancel();
    loopTimer?.cancel();
    levelTimer?.cancel();
    audio.dispose();
    for (var ca in coinAnimations) {
      ca.controller.dispose();
    }
  }

  void _loadLevelConfig() {
    final cfg = levelConfigs[level - 1];
    requiredScore = cfg['score'];
    timeLeft = cfg['time'];
    currentFishTarget = Map<String, int>.from(cfg['fishTarget']);
    fishCollected.clear();
    score = 0;
  }

  void _startSpawning() {
    fishTimer = Timer.periodic(
      Duration(milliseconds: (800 - level * 50).clamp(600, 1500)),
      (_) {
        if (!isPaused) _spawnFish();
      },
    );
  }

  void _startLoop() {
    loopTimer = Timer.periodic(Duration(milliseconds: 30), (_) {
      if (!isPaused) {
        _updateFish();
        _updateMissiles();
        _triggerMagnetUnlock();
        _redraw();
      }
    });
  }

  void _startLevelTimer() {
    levelTimer?.cancel();
    levelTimer = Timer.periodic(Duration(seconds: 1), (t) {
      if (!isPaused) {
        timeLeft--;
        if (timeLeft <= 0) {
          t.cancel();
          _completeOrFailLevel();
        }
        _redraw();
      }
    });
  }

  void _spawnFish() {
    final sz = MediaQuery.of(context).size;
    if (random.nextBool()) {
      leftFishes.add(
        Fish(
          Offset(-60, random.nextDouble() * sz.height),
          leftFishUrls[random.nextInt(leftFishUrls.length)],
          1 + random.nextDouble() * 1.5 + level * 0.2,
          direction: Offset(0.8, (random.nextDouble() * 2 - 1) * 0.3),
        ),
      );
    }
    if (random.nextBool()) {
      rightFishes.add(
        Fish(
          Offset(sz.width + 60, random.nextDouble() * sz.height),
          rightFishUrls[random.nextInt(rightFishUrls.length)],
          1 + random.nextDouble() * 1.5 + level * 0.2,
          direction: Offset(-0.8, (random.nextDouble() * 2 - 1) * 0.3),
        ),
      );
    }
  }

  void _updateFish() {
    final sz = MediaQuery.of(context).size;
    for (var f in [...leftFishes, ...rightFishes]) {
      if (!f.isHit && !f.isInNet) f.position += f.direction * f.speed;
    }
    leftFishes.removeWhere((f) => f.position.dx > sz.width + 100 || f.isHit);
    rightFishes.removeWhere((f) => f.position.dx < -100 || f.isHit);
  }

  void fireMissile(Offset target) {
    final sz = MediaQuery.of(context).size;
    final start = Offset(sz.width / 2, sz.height - 40);
    final diff = target - start;
    final mag = diff.distance;
    missiles.add(Missile(position: start, velocity: diff / mag * 10));
    missileTarget = target;
    if (isSoundOn) audio.playSoundEffect(soundNet);
  }

  void _updateMissiles() {
    if (missileTarget == null) return;
    for (var m in missiles) {
      if (!m.hasReachedTarget) {
        m.update();
        if ((m.position - missileTarget!).distance < 10) {
          m.hasReachedTarget = true;
          _triggerNetBlast(missileTarget!);
          nets.add(Net(center: missileTarget!, radius: 100));
        }
      }
    }
    missiles.removeWhere((m) => m.hasReachedTarget);
  }

  void _triggerNetBlast(Offset pos) {
    if (isSoundOn) audio.playSoundEffect(soundNet);
    final inside = [
      ...leftFishes,
      ...rightFishes,
    ].where((f) => (f.position - pos).distance < 100).toList();
    for (var f in inside) {
      f.isInNet = true;
    }
    final net = Net(center: pos, radius: 100);
    nets.add(net);

    Timer(Duration(milliseconds: 500), () {
      if (isSoundOn) audio.playSoundEffect(soundCoin);
      for (var f in inside) {
        f.isHit = true;
        final name = f.imageUrl.split('/').last;
        fishCollected[name] = (fishCollected[name] ?? 0) + 1;
        _spawnCoinAnim(f.position, 0);
        nets.remove(net);
      }
      score += inside.length;
      leftFishes.removeWhere((f) => inside.contains(f));
      rightFishes.removeWhere((f) => inside.contains(f));
      _checkLevelCompletion();
    });
  }




  void _checkLevelCompletion() {
    final cfg = levelConfigs[level - 1];
    final ft = cfg['fishTarget'];

    final success = score >= requiredScore &&
        ft.entries.every((e) => (fishCollected[e.key] ?? 0) >= e.value);

    if (success) {
      levelTimer?.cancel(); // 👈 stop the countdown timer early
      _showDialog('🎉 Level $level Complete!', 'Next', _nextLevel);
    }
  }

  // void _spawnCoinAnim(Offset pos, int delay, {VoidCallback ? onComplete}) {
  //   final ctrl = AnimationController(
  //     vsync: ticker,
  //     duration: Duration(milliseconds: 1500 + random.nextInt(500)),
  //   );
  //   final anim = Tween<Offset>(
  //     begin: pos,
  //     end: Offset(walletX, walletY),
  //   ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOutBack));
  //   final rot = Tween<double>(
  //     begin: 0,
  //     end: 2 * pi,
  //   ).animate(CurvedAnimation(parent: ctrl, curve: Curves.linear));
  //   final sc = Tween<double>(
  //     begin: 0.8,
  //     end: 1.2,
  //   ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));
  //   final ca = CoinAnimation(
  //     controller: ctrl,
  //     animation: anim,
  //     rotation: rot,
  //     scale: sc,
  //     start: pos,
  //   );
  //   coinAnimations.add(ca);
  //   Future.delayed(Duration(milliseconds: delay), () {
  //     if (isSoundOn) audio.playSoundEffect(soundCoin);
  //     ctrl.forward();
  //   });
  //   ctrl.addStatusListener((s) {
  //     if (s == AnimationStatus.completed) {
  //       coinAnimations.remove(ca);
  //       ctrl.dispose();
  //     }
  //   });
  // }

  void _spawnCoinAnim(Offset pos, int delay) {
    final ctrl = AnimationController(
      vsync: ticker,
      duration: Duration(milliseconds: 1500 + random.nextInt(500)),
    );

    final anim = Tween<Offset>(
      begin: pos,
      end: Offset(walletX, walletY),
    ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOutBack));

    final rot = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: ctrl, curve: Curves.linear));

    final sc = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));

    final ca = CoinAnimation(
      controller: ctrl,
      animation: anim,
      rotation: rot,
      scale: sc,
      start: pos,
    );

    coinAnimations.add(ca);

    Future.delayed(Duration(milliseconds: delay), () {
      if (isSoundOn) audio.playSoundEffect(soundCoin);
      ctrl.forward();
    });

    ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        coinAnimations.remove(ca);
        ctrl.dispose();

      }
    });
  }


  void _triggerMagnetUnlock() {
    if (score >= 20 && !magnetAvailable) magnetAvailable = true;
  }

  void activateMagnet() {
    if (!magnetAvailable) return;
    isMagnetActive = true;
    magnetAvailable = false;
    final center = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );
    final list = [
      ...leftFishes,
      ...rightFishes,
    ].where((f) => !f.isHit && !f.isInNet).toList();
    list.sort(
      (a, b) => (a.position - center).distance.compareTo(
        (b.position - center).distance,
      ),
    );
    final pick = list.take(15).toList();
    for (var f in pick) {
      f.isHit = true;
      final name = f.imageUrl.split('/').last;
      fishCollected[name] = (fishCollected[name] ?? 0) + 1;
      _spawnCoinAnim(f.position, 0);
    }
    score += pick.length;
    leftFishes.removeWhere((f) => pick.contains(f));
    rightFishes.removeWhere((f) => pick.contains(f));
    Timer(Duration(seconds: 1), () => isMagnetActive = false);
  }

  void _completeOrFailLevel() {
    final cfg = levelConfigs[level - 1];
    final ft = cfg['fishTarget'];

    // ✅ Check if player succeeded
    final success = score >= requiredScore &&
        ft.entries.every((e) => (fishCollected[e.key] ?? 0) >= e.value);

    if (success) {
      _showDialog('🎉 Level $level Complete!', 'Next', _nextLevel);
    } else {
      final missingFish = <String, int>{};
      ft.forEach((fish, required) {
      final collected = fishCollected[fish] ?? 0;
      if (collected < required) {
      missingFish[fish] = required - collected;
      }
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Color(0xff4b8d99),
          title: const Text('❌ Level Failed',style: TextStyle(color: Colors.white),),
          content: getMissingFishWidget(missingFish),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _retryLevel();
              },
              child: const Text('Retry',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      );
    }
  }
  Widget getMissingFishWidget(Map<String, int> missingFish) {
    if (missingFish.isEmpty) {
      return const Text("✅ No missing fish, but score was too low.",style: TextStyle(color: Colors.white),);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: missingFish.entries.map((entry) {
        final fishImageName = entry.key;
        final count = entry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Image.asset(
                'assets/images/$fishImageName',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 10),
              Text(
                'x $count more',
                style: const TextStyle(fontSize: 16,color: Colors.white),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  void _nextLevel() async {
    if (level < levelConfigs.length) {
      level++;
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('unlockedLevel', level);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadLevelConfig();
        _startLevelTimer();
      });
    } else {
      _showDialog(
        '🏁 You Completed All Levels!',
        'Exit',
            () => Navigator.popUntil(context, (r) => r.isFirst),
      );
    }
  }


  void _retryLevel() {
    _loadLevelConfig();
    _startLevelTimer();
  }

  void _showDialog(String title, String btnText, VoidCallback cb) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xff4b8d99),
        title: Text(title, style: TextStyle(fontSize: 18,color: Colors.white)),
        content: title.contains("Game Over")
            ? Text(title.split('\n\n').last, style: TextStyle(fontSize: 14,color: Colors.white))
            : null,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cb();
            },
            child: Text(btnText,style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  Widget buildGameUI() {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(bgAsset, fit: BoxFit.cover)),
          for (var f in leftFishes) FishWidget(fish: f, blastGif: blastGif),
          for (var f in rightFishes) FishWidget(fish: f, blastGif: blastGif),
          for (var m in missiles)
            MissileWidget(missile: m, missileAsset: missileAsset),
          for (var ca in coinAnimations)
            CoinAnimationWidget(coinAnim: ca, coinImage: coinAsset),
          for (var net in nets)
            Positioned(
              left: net.center.dx - net.radius,
              top: net.center.dy - net.radius,
              child: Image.asset(
                netAsset,
                width: net.radius * 2,
                height: net.radius * 2,
              ),
            ),
          Positioned(
            top: 10,
            left: 20,
            child: Text(
              'Score: $score / $requiredScore',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Positioned(
            top: 10,
            left: 160,
            child: Text(
              'Level: $level',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Positioned(
            top: 10,
            right: 20,
            child: Text(
              '⏱ $timeLeft',
              style: TextStyle(
                color: timeLeft <= 10 ? Colors.red : Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: currentFishTarget.entries.map((e) {
                final have = fishCollected[e.key] ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/${e.key}',
                      width: 30,
                      height: 35,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$have / ${e.value}',
                      style: TextStyle(
                        color: have >= e.value ? Colors.greenAccent : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (magnetAvailable && !isMagnetActive)
            Positioned(
              bottom: 100,
              right: 20,
              child: GestureDetector(
                onTap: activateMagnet,
                child: Icon(Icons.star, color: Colors.amber, size: 60),
              ),
            ),
          Positioned(
            top: 10,
            right: 80,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isSoundOn ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                  ),
                  onPressed: () => isSoundOn = !isSoundOn,
                ),
                IconButton(
                  icon: Icon(
                    isMusicOn ? Icons.music_note : Icons.music_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    isMusicOn = !isMusicOn;
                    if (isMusicOn) {
                      audio.playBackgroundMusic(musicAsset);
                    } else {
                      audio.stopBackgroundMusic();
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (d) => fireMissile(d.localPosition),
            ),
          ),
        ],
      ),
    );
  }

  void _redraw() => WidgetsBinding.instance.addPostFrameCallback(
    (_) => (context as Element).markNeedsBuild(),
  );
}
