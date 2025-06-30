import 'package:fish_game/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sniper_game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int unlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadUnlocked();
  }

  Future<void> _loadUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      unlockedLevel = prefs.getInt('unlockedLevel') ?? 1;
    });
  }

  void _onLevelTap(int level) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SniperGameScreen(startLevel: level)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:Color(0xff4b8d99),
      title: const Text("Select Level", textAlign: TextAlign.center,style: TextStyle(color: Colors.white),),
      content: SizedBox(
        width: width*0.5,
        height: height*0.25,
        child: GridView.builder(
          itemCount: 10,
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          itemBuilder: (BuildContext context, int i) {
            final lvl = i + 1;
            return InkWell(
              onTap: lvl <= unlockedLevel ? () => _onLevelTap(lvl) : null,
              child: Center(
                child: Container(
                  width: width*0.07,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: lvl <= unlockedLevel ? Color(0xffabdbda) : Colors.grey.shade400,
                  ),
                  child: Center(child: Text('$lvl',style: TextStyle(color: Colors.white))),
                ),
              ),
            );
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
          ),
        ),
      ),
    );
  }
}
