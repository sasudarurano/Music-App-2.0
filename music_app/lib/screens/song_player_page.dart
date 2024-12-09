import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:just_audio/just_audio.dart';
import 'package:music_app/models/song_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_app/controllers/songController.dart'; // Import SongController

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
  // Use GetXController to manage the current song
  final _songController = Get.put(SongController());

  bool _isFavorite = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.songs.indexOf(widget.song);
    _songController.currentSong.value = widget.song; // Initialize current song
    _initAudioPlayer();
    _checkFavoriteStatus();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await widget.audioPlayer.setAsset(widget.song.audioPath);
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
      _songController.currentSong.value =
          song; // Update the current song in the controller
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Player'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use Obx to update the image when the song changes
          Obx(() => CircleAvatar(
                radius: 100,
                backgroundImage:
                    AssetImage(_songController.currentSong.value.imagePath),
              )),
          const SizedBox(height: 32),
          // Use Obx to update the title when the song changes
          Obx(() => Text(
                _songController.currentSong.value.title,
                style: const TextStyle(fontSize: 24),
              )),
          // Use Obx to update the artist when the song changes
          Obx(() => Text(
                _songController.currentSong.value.artist,
                style: const TextStyle(fontSize: 18),
              )),
          const SizedBox(height: 32),
          StreamBuilder<Duration>(
            stream: widget.audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              return Slider(
                min: 0.0,
                max: widget.audioPlayer.duration?.inMilliseconds.toDouble() ??
                    0.0,
                value: position.inMilliseconds.toDouble(),
                onChanged: (value) {
                  widget.audioPlayer
                      .seek(Duration(milliseconds: value.toInt()));
                },
              );
            },
          ),
          StreamBuilder<Duration>(
            stream: widget.audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position)),
                    StreamBuilder<Duration?>(
                      stream: widget.audioPlayer.durationStream,
                      builder: (context, snapshot) {
                        final duration = snapshot.data ?? Duration.zero;
                        return Text(_formatDuration(duration));
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: _playPreviousSong, // Call _playPreviousSong
              ),
              StreamBuilder<PlayerState>(
                stream: widget.audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return const CircularProgressIndicator();
                  } else if (playing != true) {
                    return IconButton(
                      icon: const Icon(Icons.play_arrow),
                      iconSize: 64,
                      onPressed: widget.audioPlayer.play,
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return IconButton(
                      icon: const Icon(Icons.pause),
                      iconSize: 64,
                      onPressed: widget.audioPlayer.pause,
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(Icons.replay),
                      iconSize: 64,
                      onPressed: () => widget.audioPlayer.seek(Duration.zero),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: _playNextSong, // Call _playNextSong
              ),
            ],
          ),
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

