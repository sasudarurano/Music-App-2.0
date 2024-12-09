import 'package:flutter/material.dart';
import 'package:music_app/models/song_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_app/screens/song_player_page.dart'; // Import for SongPlayerPage
import 'package:just_audio/just_audio.dart'; // Import for AudioPlayer

class FavoriteSongsPage extends StatefulWidget {
  const FavoriteSongsPage({Key? key}) : super(key: key);

  @override
  State<FavoriteSongsPage> createState() => _FavoriteSongsPageState();
}

class _FavoriteSongsPageState extends State<FavoriteSongsPage> {
  List<Song> favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteSongs();
  }

  Future<void> _loadFavoriteSongs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final songTitles = prefs.getKeys().where((key) => !key.contains('-')).toList();

      setState(() {
        favoriteSongs = songTitles.map((title) => Song(
          title: title,
          artist: prefs.getString('$title-artist') ?? 'Unknown Artist',
          imagePath: prefs.getString('$title-imagePath') ?? 'assets/images/default.png',
          audioPath: prefs.getString('$title-audioPath') ?? 'assets/audio/default.mp3',
        )).toList();
      });
    } catch (e) {
      print('Error loading favorite songs: $e');
      // Consider showing a SnackBar or a dialog to inform the user
    }
  }

  Future<void> _removeSongFromFavorites(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(song.title);
    await prefs.remove('${song.title}-artist');
    await prefs.remove('${song.title}-imagePath');
    await prefs.remove('${song.title}-audioPath');

    setState(() {
      favoriteSongs.remove(song);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
      ),
      body: ListView.builder(
        itemCount: favoriteSongs.length,
        itemBuilder: (context, index) {
          final song = favoriteSongs[index];
          return ListTile(
            leading: Image.asset(song.imagePath),
            title: Text(song.title),
            subtitle: Text(song.artist),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                _removeSongFromFavorites(song);
              },
            ),
            // Add the onTap functionality here
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongPlayerPage(

                    audioPlayer: AudioPlayer(), // Create a new AudioPlayer instance
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