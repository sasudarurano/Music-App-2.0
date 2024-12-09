import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'song_player_page.dart'; // Ganti dengan nama file halaman song player
import 'package:music_app/models/song_model.dart';
import 'favorite_songs_page.dart'; // Import halaman favorite songs
import 'profile_page.dart'; // Import halaman profile

class SongListPage extends StatefulWidget {
  const SongListPage({Key? key}) : super(key: key);

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final _audioPlayer = AudioPlayer();
  List<Song> songs = []; // Ganti dengan data lagu dari assets

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    // Load data lagu dari assets
    setState(() {
      songs = [
        Song(
          title: 'Lagu 1',
          artist: 'Artis 1',
          imagePath: 'assets/images/gambar1.jpeg', // Ganti dengan path gambar
          audioPath: 'assets/audio/lagu1.mp3', // Ganti dengan path audio
        ),
        // Tambahkan lagu lainnya di sini
      ];
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // Navigasi ke halaman Favorite Songs
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FavoriteSongsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigasi ke halaman Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return ListTile(
            leading: Image.asset(song.imagePath),
            title: Text(song.title),
            subtitle: Text(song.artist),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongPlayerPage(
                      audioPlayer: _audioPlayer,
                      song: song,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}