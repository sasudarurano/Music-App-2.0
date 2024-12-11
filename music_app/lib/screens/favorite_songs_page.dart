import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/songController.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/screens/song_player_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteSongsPage extends StatefulWidget {
  const FavoriteSongsPage({Key? key}) : super(key: key);

  @override
  State<FavoriteSongsPage> createState() => _FavoriteSongsPageState();
}

class _FavoriteSongsPageState extends State<FavoriteSongsPage> {
  final _songController = Get.find<SongController>();
  List<Song> favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteSongs();
  }

  Future<void> _loadFavoriteSongs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final songTitles =
          prefs.getKeys().where((key) => !key.contains('-')).toList();

      List<Song> loadedSongs = songTitles.map((title) {
        final artist = prefs.getString('$title-artist');
        final imagePath = prefs.getString('$title-imagePath');
        final audioPath = prefs.getString('$title-audioPath');

        if (artist != null && imagePath != null && audioPath != null) {
          return Song(
            title: title,
            artist: artist,
            imagePath: imagePath,
            audioPath: audioPath,
          );
        } else {
          return null;
        }
      }).whereType<Song>().toList();

      setState(() {
        favoriteSongs = loadedSongs;
      });
    } catch (e) {
      print('Error loading favorite songs: $e');
    }
  }

  Future<void> _removeSongFromFavorites(Song song) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(song.title);
      await prefs.remove('${song.title}-artist');
      await prefs.remove('${song.title}-imagePath');
      await prefs.remove('${song.title}-audioPath');

      // Remove the song from the controller if it's the current song
      if (_songController.currentSong.value.title == song.title) {
        _songController.currentSong.value = Song(
          title: '',
          artist: '',
          imagePath: '',
          audioPath: '',
        );
      }

      setState(() {
        favoriteSongs.remove(song);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${song.title} removed from favorites.')),
      );
    } catch (e) {
      print('Error removing song: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
        centerTitle: true,
      ),
      body: favoriteSongs.isEmpty
          ? const Center(
              child: Text('No favorite songs found.'),
            )
          : ListView.builder(
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return ListTile(
                  leading: Image.asset(
                    song.imagePath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _removeSongFromFavorites(song),
                  ),
                  onTap: () {
                    _songController.currentSong.value = song;
                    _songController.isPlaying.value = true;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongPlayerPage(
                          audioPlayer: _songController.audioPlayer,
                          songs: favoriteSongs,
                          song: song,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
