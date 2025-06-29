// import 'package:flutter/material.dart';
//
// class GameOverScreen extends StatefulWidget {
//   final Map<String,int> missing;
//   const GameOverScreen({super.key, required this.missing});
//
//   @override State<GameOverScreen> createState() => _GameOverScreenState();
// }
//
// class _GameOverScreenState extends State<GameOverScreen> with TickerProviderStateMixin {
//   late AnimationController _ctr;
//   late Animation<double> _fade;
//
//   @override
//   void initState(){
//     super.initState();
//     _ctr = AnimationController(vsync: this, duration: Duration(seconds: 2));
//     _fade = CurvedAnimation(parent: _ctr, curve: Curves.easeIn);
//     _ctr.forward();
//   }
//
//   @override void dispose(){
//     _ctr.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext ctx){
//     return Scaffold(
//       backgroundColor: Colors.black87,
//       body: FadeTransition(
//         opacity: _fade,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('Game Over', style: TextStyle(fontSize: 36, color: Colors.red)),
//               const SizedBox(height: 20),
//               ...widget.missing.entries.map((e)=>Text('${e.key}: ${e.value} more', style: TextStyle(color: Colors.white))),
//               const SizedBox(height: 30),
//               ElevatedButton(onPressed: ()=>Navigator.pop(ctx), child: Text('Retry')),
//               ElevatedButton(onPressed: ()=>Navigator.pushReplacementNamed(ctx, '/'), child: Text('Home')),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
