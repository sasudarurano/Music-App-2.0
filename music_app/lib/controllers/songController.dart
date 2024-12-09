import 'package:get/get.dart'; 
import 'package:music_app/models/song_model.dart';

// Create a SongController class
class SongController extends GetxController {
  // Use Rx<Song> to make currentSong observable
  final currentSong = Song(
          title: 'Default Title',
          artist: 'Default Artist',
          imagePath: 'assets/images/default.png',
          audioPath: 'assets/audio/default.mp3')
      .obs;
}