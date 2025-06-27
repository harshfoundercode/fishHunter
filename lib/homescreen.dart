import 'package:fish_game/tester/game_screen.dart';
import 'package:fish_game/tester/game_screen_2.dart' show SniperGame2;
import 'package:flutter/material.dart';
import 'fish_game_new.dart';
import 'generated/assets.dart' show Assets;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _totalLevels = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/bg3.png'),fit: BoxFit.fill)
        ),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Fish Hunter',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Image.asset('assets/images/fish6.gif', width: 150),
            SizedBox(height: 20),
            // Container(
            //   width: 400,
            //   height: 130,
            //   child: GridView.builder(
            //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //       crossAxisCount: 3, // 3 columns
            //       childAspectRatio: 3, // Square buttons
            //       crossAxisSpacing: 15,
            //       mainAxisSpacing: 15,
            //     ),
            //     itemCount: _totalLevels,
            //     itemBuilder: (context, index) {
            //       int level = index + 1;
            //       bool isLocked = level > 5; // First 5 levels unlocked
            //
            //       return LevelButton(
            //         level: level,
            //         isLocked: isLocked,
            //         onPressed: () {
            //           if (!isLocked) {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => FishGameScreenNew(level: level),
            //               ),
            //             );
            //           }
            //         },
            //       );
            //     },
            //   ),
            // ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'PLAY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        // FishGameScreenNew(level: 1),
                    // SniperScreen(),
                    SniperGame2(),
                  ),
                );
              },
            ),
          ],
        ),
      )


    );
  }
}

class LevelButton extends StatelessWidget {
  final int level;
  final bool isLocked;
  final VoidCallback onPressed;

  const LevelButton({
    super.key,
    required this.level,
    required this.isLocked,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Center(
        child: Container(
          width: 50,
          decoration: BoxDecoration(
            color: isLocked ? Colors.grey : Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  '$level',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isLocked)
                Center(
                  child: Icon(Icons.lock, size: 12, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}