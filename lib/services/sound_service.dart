import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playRotateSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/rotate.mp3'));
    } catch (e) {
      // Silent fail if sound file is missing
    }
  }

  Future<void> playDropSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/drop.mp3'));
    } catch (e) {
      // Silent fail if sound file is missing
    }
  }

  Future<void> playLineClearSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/line_clear.mp3'));
    } catch (e) {
      // Silent fail if sound file is missing
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}