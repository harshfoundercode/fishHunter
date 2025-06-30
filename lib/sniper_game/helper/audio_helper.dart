import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  final _player = AudioPlayer();

  Future<void> playSoundEffect(String assetPath) async {
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      print('Audio Error: $e');
    }
  }
//gggg
  Future<void> playBackgroundMusic(String assetPath) async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(assetPath)); // ✅
    } catch (e) {
      print('Music Error: $e');
    }
  }

  void stopBackgroundMusic() {
    _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
