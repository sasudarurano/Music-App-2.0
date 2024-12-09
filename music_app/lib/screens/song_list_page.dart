import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'song_player_page.dart';
import 'package:music_app/models/song_model.dart';
import 'favorite_songs_page.dart';
import 'profile_page.dart';

class SongListPage extends StatefulWidget {
  const SongListPage({Key? key}) : super(key: key);

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final _audioPlayer = AudioPlayer();
  List<Song> songs = [];
  Song? _currentSong;
  bool _isPlaying = false;

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
          title: 'ラブカ？ / konoco(cover)',
          artist: 'konoco',
          imagePath: 'assets/images/gambar1.jpeg',
          audioPath: 'assets/audio/lagu11.mp3',
        ),
        Song(
          title: 'KEEP UP (Keep up Im too fast Im too fast...) ( Slowed & Reverbed ) /// Pink Fox Lady ///',
          artist: 'Odetari',
          imagePath: 'assets/images/gambar2.jpeg',
          audioPath: 'assets/audio/lagu2.mp3',
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                            songs: songs, // Pass the list of songs here
                            song: song,
                          ),
                        ),
                      ).then((_) {
                        setState(() {
                          _currentSong = _audioPlayer.playing ? song : null;
                          _isPlaying = _audioPlayer.playing;
                        });
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // Widget untuk menampilkan lagu yang sedang diputar
          if (_currentSong != null)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[300],
              child: Row(
                children: [
                  Image.asset(_currentSong!.imagePath, width: 50, height: 50),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_currentSong!.title,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(_currentSong!.artist),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        if (_isPlaying) {
                          _audioPlayer.pause();
                        } else {
                          _audioPlayer.play();
                        }
                        _isPlaying = !_isPlaying;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}