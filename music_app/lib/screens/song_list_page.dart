import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'song_player_page.dart';
import 'package:music_app/models/song_model.dart';
import 'favorite_songs_page.dart';
import 'profile_page.dart';
import 'package:music_app/controllers/songController.dart';

class SongListPage extends StatefulWidget {
  const SongListPage({Key? key}) : super(key: key);

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final _songController = Get.put(SongController());
  final _scrollController = ScrollController();
  List<Song> songs = [];
  List<Song> displayedSongs = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _songController.audioPlayer.playerStateStream.listen((playerState) {
      _songController.isPlaying.value = playerState.playing;
    });
    _songController.audioPlayer.positionStream.listen((position) {
      _songController.currentPosition.value = position;
    });
  }

  Future<void> _loadSongs() async {
    setState(() {
      songs = [
        Song(
          title: 'ラブカ？ / konoco(cover)',
          artist: 'konoco',
          imagePath: 'assets/images/gambar1.jpeg',
          audioPath: 'assets/audio/lagu11.mp3',
        ),
        Song(
          title:
              'KEEP UP (Keep up Im too fast Im too fast...) ( Slowed & Reverbed ) /// Pink Fox Lady ///',
          artist: 'Odetari',
          imagePath: 'assets/images/gambar2.jpeg',
          audioPath: 'assets/audio/lagu2.mp3',
        ),
        Song(
          title: 'Indila - Dernière Danse (SLOWED + Reverb)',
          artist: 'Indila',
          imagePath: 'assets/images/download (15).jpeg',
          audioPath: 'assets/audio/derniere.mp3',
        ),
        Song(
          title: 'stephanie poetri - i love you 3000 (slowed down)',
          artist: 'stephanie poetri',
          imagePath: 'assets/images/🎀follow me!.jpeg',
          audioPath: 'assets/audio/i3000.mp3',
        ),
        Song(
          title: 'SoapSkin  Me and the Devil SLOWED  TIKTOK Version',
          artist: 'Soap&Skin',
          imagePath: 'assets/images/download (16).jpeg',
          audioPath: 'assets/audio/mendevil.mp3',
        ),
        Song(
          title: 'VAPO NO SETOR (BASHAME VERSION)',
          artist: 'Bashame',
          imagePath: 'assets/images/bashame.jpeg',
          audioPath: 'assets/audio/utomp3.com - VAPO NO SETOR BASHAME VERSION.mp3',
        ),
        Song(
          title: ' ENGLISH COVER Love Me Love Me Love Me Nerissa Ravencroft',
          artist: 'Nerissa Ravencroft',
          imagePath: 'assets/images/𝘯𝘦𝘳𝘪𝘴𝘴𝘢 𝘳𝘢𝘷𝘦𝘯𝘤𝘳𝘰𝘧𝘵_.jpeg',
          audioPath: 'assets/audio/utomp3.com - ENGLISH COVERLove Me Love Me Love Me Nerissa Ravencroft.mp3',
        ),
      ];
      displayedSongs = List.from(songs);
    });
  }

  @override
  void dispose() {
    _songController.audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentSong() {
    final currentIndex = songs.indexOf(_songController.currentSong.value);
    if (currentIndex != -1) {
      _scrollController.animateTo(
        currentIndex * 72.0, // Adjust this value if needed
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterSongs();
    });
  }

  void _filterSongs() {
    displayedSongs = songs.where((song) {
      final titleMatch =
          song.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final artistMatch =
          song.artist.toLowerCase().contains(_searchQuery.toLowerCase());
      return titleMatch || artistMatch;
    }).toList();
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search songs...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              controller: _scrollController,
              itemCount: displayedSongs.length,
              itemBuilder: (context, index) {
                final song = displayedSongs[index];
                return GestureDetector(
                  onTap: () async {
                    if (_songController.currentSong.value != song) {
                      await _songController.audioPlayer.stop();
                      _songController.currentSong.value = song;
                      await _songController.audioPlayer.setAudioSource(
                          AudioSource.asset(song.audioPath));
                    }
                    _songController.isPlaying.value = true;
                    _songController.audioPlayer.play();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongPlayerPage(
                          audioPlayer: _songController.audioPlayer,
                          songs: songs,
                          song: song,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Ink.image(
                            image: AssetImage(song.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                song.artist,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Obx(() {
            if (_songController.currentSong.value.title.isNotEmpty) {
              return GestureDetector(
                onTap: () {
                  _scrollToCurrentSong();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongPlayerPage(
                        audioPlayer: _songController.audioPlayer,
                        songs: songs,
                        song: _songController.currentSong.value,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.grey[300],
                  child: Row(
                    children: [
                      Image.asset(
                        _songController.currentSong.value.imagePath,
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_songController.currentSong.value.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(_songController.currentSong.value.artist),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Obx(() => Icon(_songController.isPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow)),
                        onPressed: () {
                          _songController.isPlaying.value
                              ? _songController.audioPlayer.pause()
                              : _songController.audioPlayer.play();
                        },
                      ),
                      // Display the current position
                      Obx(() => Text(
                            _formatDuration(_songController
                                    .currentPosition.value ??
                                Duration.zero),
                          )),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}