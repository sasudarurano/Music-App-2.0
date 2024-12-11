import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/models/song_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_app/controllers/songController.dart';

class SongPlayerPage extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final List<Song> songs;
  final Song song;

  const SongPlayerPage({
    Key? key,
    required this.audioPlayer,
    required this.songs,
    required this.song,
  }) : super(key: key);

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  final _songController = Get.find<SongController>();
  bool _isFavorite = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.songs.indexOf(widget.song);
    _songController.currentSong.value = widget.song;
    _initAudioPlayer();
    _checkFavoriteStatus();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await widget.audioPlayer.setAsset(widget.song.audioPath);

      // Set the initial position of the audioPlayer
      final initialPosition = _songController.currentPosition.value;
      if (initialPosition != null) {
        await widget.audioPlayer.seek(initialPosition);
      }

      await widget.audioPlayer.play();
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = prefs.getBool(widget.song.title) ?? false;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = !_isFavorite;
      prefs.setBool(widget.song.title, _isFavorite);
      if (_isFavorite) {
        prefs.setString('${widget.song.title}-artist', widget.song.artist);
        prefs.setString(
            '${widget.song.title}-imagePath', widget.song.imagePath);
        prefs.setString(
            '${widget.song.title}-audioPath', widget.song.audioPath);
      } else {
        prefs.remove('${widget.song.title}-artist');
        prefs.remove('${widget.song.title}-imagePath');
        prefs.remove('${widget.song.title}-audioPath');
      }
    });
  }

  void _playPreviousSong() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _playSongAtIndex(_currentIndex);
    }
  }

  void _playNextSong() {
    if (_currentIndex < widget.songs.length - 1) {
      _currentIndex++;
      _playSongAtIndex(_currentIndex);
    }
  }

  Future<void> _playSongAtIndex(int index) async {
    final song = widget.songs[index];
    try {
      await widget.audioPlayer.stop();
      await widget.audioPlayer.setAsset(song.audioPath);
      await widget.audioPlayer.play();
      _songController.currentSong.value = song;
      _checkFavoriteStatus(); // Refresh favorite status
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: Colors.black,
            onPressed: _toggleFavorite,
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[800]!, Colors.black],
          ),
        ),
        child: Column(
          children: [
            // Top section with image and controls
            Obx(
              () => Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        _songController.currentSong.value.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      top: 100,
                      left: 20,
                      child: Text(
                        "NOW PLAYING",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom section with song info and controls
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Song title and artist
                      Column(
                        children: [
                          Obx(
                            () => Text(
                              _songController.currentSong.value.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Obx(
                            () => Text(
                              _songController.currentSong.value.artist,
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      // Slider
                      Column(
                        children: [
                          SizedBox(
                            height: 40,
                            child: StreamBuilder<Duration>(
                              stream: widget.audioPlayer.positionStream,
                              builder: (context, snapshot) {
                                final position =
                                    snapshot.data ?? Duration.zero;
                                return SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    thumbShape:
                                        const RoundSliderThumbShape(
                                            enabledThumbRadius: 8),
                                    trackShape:
                                        const RectangularSliderTrackShape(),
                                    trackHeight: 4,
                                  ),
                                  child: Slider(
                                    min: 0.0,
                                    max: widget.audioPlayer.duration
                                            ?.inMilliseconds
                                            .toDouble() ??
                                        1.0, // Use 1.0 as a default
                                    value: position.inMilliseconds
                                        .toDouble(),
                                    onChanged: (value) {
                                      widget.audioPlayer
                                          .seek(Duration(
                                              milliseconds:
                                                  value.toInt()))
                                          .catchError((error) {
                                        // Handle seek errors if necessary
                                        print("Error seeking: $error");
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          StreamBuilder<Duration>(
                            stream: widget.audioPlayer.positionStream,
                            builder: (context, snapshot) {
                              final position = snapshot.data ?? Duration.zero;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDuration(position)),
                                    StreamBuilder<Duration?>(
                                      stream:
                                          widget.audioPlayer.durationStream,
                                      builder: (context, snapshot) {
                                        final duration =
                                            snapshot.data ?? Duration.zero;
                                        return Text(_formatDuration(duration));
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      // Playback controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous, size: 40),
                            onPressed: _playPreviousSong,
                          ),
                          StreamBuilder<PlayerState>(
                            stream: widget.audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              final playerState = snapshot.data;
                              final processingState =
                                  playerState?.processingState;
                              final playing = playerState?.playing;
                              if (processingState ==
                                      ProcessingState.loading ||
                                  processingState ==
                                      ProcessingState.buffering) {
                                return const CircularProgressIndicator(
                                  color: Colors.black,
                                );
                              } else if (playing != true) {
                                return IconButton(
                                  icon: const Icon(Icons.play_circle_fill,
                                      size: 60, color: Colors.black),
                                  onPressed: widget.audioPlayer.play,
                                );
                              } else if (processingState !=
                                  ProcessingState.completed) {
                                return IconButton(
                                  icon: const Icon(Icons.pause_circle_filled,
                                      size: 60, color: Colors.black),
                                  onPressed: widget.audioPlayer.pause,
                                );
                              } else {
                                return IconButton(
                                  icon: const Icon(
                                      Icons.replay_circle_filled,
                                      size: 60,
                                      color: Colors.black),
                                  onPressed: () async {
                                    await widget.audioPlayer
                                        .seek(Duration.zero); // Replay from start
                                    await widget.audioPlayer.play();
                                  },
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next, size: 40),
                            onPressed: _playNextSong,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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