import 'package:flutter/material.dart';
import 'package:music_app/models/song_model.dart';


class FavoriteSongsPage extends StatefulWidget {
  const FavoriteSongsPage({Key? key}) : super(key: key);

  @override
  State<FavoriteSongsPage> createState() => _FavoriteSongsPageState();
}

class _FavoriteSongsPageState extends State<FavoriteSongsPage> {
  List<Song> favoriteSongs = []; // Ganti dengan data lagu favorit

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
              icon: const Icon(Icons.favorite),
              onPressed: () {
                // Implementasi logika untuk menghapus lagu dari favorit
              },
            ),
          );
        },
      ),
    );
  }
}