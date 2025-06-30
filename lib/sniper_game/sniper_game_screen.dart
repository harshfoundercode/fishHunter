import 'package:fish_game/main.dart';
import 'package:flutter/material.dart';
import 'game_controller.dart';

class SniperGameScreen extends StatefulWidget {
  final int startLevel;
  const SniperGameScreen({super.key, required this.startLevel,});
  @override
  State<SniperGameScreen> createState() => _SniperGameScreenState();
}

class _SniperGameScreenState extends State<SniperGameScreen> with TickerProviderStateMixin {
  late GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController(context, this, widget.startLevel);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLevelTargetDialog(widget.startLevel);
    });
  }
  void _showLevelTargetDialog(int level) {
    final cfg = GameController.levelConfigs[level - 1];
    final requiredScore = cfg['score'];
    final timeLimit = cfg['time'];
    final fishTarget = cfg['fishTarget'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Color(0xff4b8d99),
        child: SizedBox(
          width: width*0.06,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎯 Level $level Goal',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                 SizedBox(height: height*0.04),

                // Score
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: width*0.02),
                    Text(
                      'Required Score: $requiredScore',
                      style: TextStyle(fontSize: 16,color: Colors.white),
                    ),
                  ],
                ),

                // Time
                SizedBox(height: height*0.03),
                Row(
                  children: [
                    Icon(Icons.timer, color: Colors.redAccent),
                    SizedBox(width: width*0.02),
                    Text(
                      'Time Limit: $timeLimit sec',
                      style: TextStyle(fontSize: 16,color: Colors.white),
                    ),
                  ],
                ),

                // Fish Targets
                if (fishTarget.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Fish Target:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: height*0.03),
                  Row(
                    children: [
                      for (var entry in fishTarget.entries)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/${entry.key}',
                              width: 50,
                              height: 50,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(width: width*0.02),
                            Text(
                              '${entry.value}',
                              style: TextStyle(fontSize: 15,color: Colors.white),
                            ),
                          ],
                        ),
                    ],
                  )

                ],

                SizedBox(height: height*0.035),
                ElevatedButton.icon(
                  onPressed: (){
                      Navigator.pop(context);
                      controller.level = level;
                      controller.init();
                  },
                  icon: Icon(Icons.play_arrow,color: Colors.white),
                  label: Text('Start Level',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff3e8c9d),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controller.buildGameUI();
  }
}
