import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/models/song_model.dart';
import 'package:flutter/foundation.dart';

class SongController extends GetxController {
  final audioPlayer = AudioPlayer();
  var isPlaying = false.obs;
  var currentSong = Song(
          title: '',
          artist: '',
          imagePath: 'assets/images/default.png',
          audioPath: 'assets/audio/default.mp3')
      .obs;

  // Use an Rx<Duration> for currentPosition
  var currentPosition = Duration.zero.obs; 
  var duration = ''.obs;
  var position = ''.obs;

  var max = 0.0.obs;
  var value = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    // Listen to positionStream to update currentPosition
    audioPlayer.positionStream.listen((position) {
      currentPosition.value = position;
    });
  }

  void updatePosition() {
    audioPlayer.durationStream.listen((d) {
      duration.value = d.toString().split(".")[0];
      max.value = d!.inSeconds.toDouble();
    });

    audioPlayer.positionStream.listen((p) {
      position.value = p.toString().split(".")[0];
      value.value = p.inSeconds.toDouble();
    });
  }

  Future<void> playSong(Song song) async {
    try {
      currentSong.value = song;
      await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.audioPath)));
      audioPlayer.play();
      updatePosition();
      isPlaying.value = true;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      debugPrint(e.toString());
    }
  }

  void pauseSong() {
    audioPlayer.pause();
    isPlaying.value = false;
  }

  void resumeSong() {
    audioPlayer.play();
    isPlaying.value = true;
  }

  void stopSong() {
    audioPlayer.stop();
    isPlaying.value = false;
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
  }
}