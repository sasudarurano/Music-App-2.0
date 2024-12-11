import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'song_player_page.dart';
import 'package:music_app/models/song_model.dart';
import 'favorite_songs_page.dart';
import 'profile_page.dart';
import 'package:music_app/controllers/songController.dart';
import 'favorite_songs_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          title: 'KEEP UP (Slowed & Reverbed)',
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
          title: 'Stephanie Poetri - I Love You 3000 (Slowed Down)',
          artist: 'Stephanie Poetri',
          imagePath: 'assets/images/🎀follow me!.jpeg',
          audioPath: 'assets/audio/i3000.mp3',
        ),
        Song(
          title: 'Soap&Skin - Me and the Devil (SLOWED)',
          artist: 'Soap&Skin',
          imagePath: 'assets/images/download (16).jpeg',
          audioPath: 'assets/audio/mendevil.mp3',
        ),
        Song(
          title: 'Vapo No Setor (Bashame Version)',
          artist: 'Bashame',
          imagePath: 'assets/images/bashame.jpeg',
          audioPath: 'assets/audio/vapo.mp3',
        ),
        Song(
          title: 'Love Me Love Me Love Me (English Cover)',
          artist: 'Nerissa Ravencroft',
          imagePath: 'assets/images/𝘯𝘦𝘳𝘪𝘴𝘴𝘢 𝘳𝘢𝘷𝘦𝘯𝘤𝘳𝘰𝘧𝘵_.jpeg',
          audioPath: 'assets/audio/love_me.mp3',
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
        currentIndex * 72.0,
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
                  builder: (context) => const FavoriteSongsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
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
                        AudioSource.asset(song.audioPath),
                      );
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
            final currentSong = _songController.currentSong.value;
            return Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey.shade200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          currentSong.imagePath,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentSong.artist,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: () {
                          _playPreviousSong();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _songController.isPlaying.value
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () {
                          if (_songController.isPlaying.value) {
                            _songController.pauseSong();
                          } else {
                            _songController.resumeSong();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: () {
                          _playNextSong();
                        },
                      ),
                    ],
                  ),
                  Obx(() {
                    final position = _songController.currentPosition.value;
                    final duration = _songController.audioPlayer.duration ?? Duration.zero;
                    return Column(
                      children: [
                        Slider(
                          value: position.inSeconds.toDouble(),
                          max: duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            _songController.seekTo(Duration(seconds: value.toInt()));
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position)),
                            Text(_formatDuration(duration)),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _playPreviousSong() {
    final currentIndex = songs.indexOf(_songController.currentSong.value);
    if (currentIndex > 0) {
      final previousSong = songs[currentIndex - 1];
      _songController.playSong(previousSong);
      _scrollToCurrentSong(); 
    }
  }


  void _playNextSong() {
    final currentIndex = songs.indexOf(_songController.currentSong.value);
    if (currentIndex < songs.length - 1) {
      final nextSong = songs[currentIndex + 1];
      _songController.playSong(nextSong);
      _scrollToCurrentSong(); 
    }
  }

  Future<void> _toggleFavorite(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final isFavorite = prefs.getBool(song.title) ?? false;
    setState(() {
      prefs.setBool(song.title, !isFavorite);
      if (!isFavorite) {
        prefs.setString('${song.title}-artist', song.artist);
        prefs.setString('${song.title}-imagePath', song.imagePath);
        prefs.setString('${song.title}-audioPath', song.audioPath);
      } else {
        prefs.remove('${song.title}-artist');
        prefs.remove('${song.title}-imagePath');
        prefs.remove('${song.title}-audioPath');
      }
    });
  }
}