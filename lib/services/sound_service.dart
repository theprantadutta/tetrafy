import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playRotateSound() async {
    await _audioPlayer.play(AssetSource('sounds/rotate.mp3'));
  }

  Future<void> playDropSound() async {
    await _audioPlayer.play(AssetSource('sounds/drop.mp3'));
  }

  Future<void> playLineClearSound() async {
    await _audioPlayer.play(AssetSource('sounds/line_clear.mp3'));
  }
}