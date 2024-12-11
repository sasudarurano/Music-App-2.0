import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/models/song_model.dart';

class SongController extends GetxController {
  var currentSong = Song(
          title: '',
          artist: '',
          imagePath: 'assets/images/default.png',
          audioPath: 'assets/audio/default.mp3')
      .obs;
  var isPlaying = false.obs;
  final audioPlayer = AudioPlayer(); // Single instance of AudioPlayer

  Rxn<Duration> currentPosition = Rxn<Duration>();
}