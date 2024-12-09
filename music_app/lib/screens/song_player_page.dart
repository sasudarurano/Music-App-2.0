import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/models/song_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongPlayerPage extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Song song;

  const SongPlayerPage({
    Key? key,
    required this.audioPlayer,
    required this.song,
  }) : super(key: key);

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _checkFavoriteStatus();
  }

  Future<void> _initAudioPlayer() async {
    await widget.audioPlayer.setAsset(widget.song.audioPath);
    await widget.audioPlayer.play();
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
      // Store song details when adding to favorites
      prefs.setString('${widget.song.title}-artist', widget.song.artist);
      prefs.setString('${widget.song.title}-imagePath', widget.song.imagePath);
      prefs.setString('${widget.song.title}-audioPath', widget.song.audioPath);
    } else {
      // Remove song details when removing from favorites
      prefs.remove('${widget.song.title}-artist');
      prefs.remove('${widget.song.title}-imagePath');
      prefs.remove('${widget.song.title}-audioPath');
    }
  });
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
          CircleAvatar(
            radius: 100,
            backgroundImage: AssetImage(widget.song.imagePath),
          ),
          const SizedBox(height: 32),
          Text(
            widget.song.title,
            style: const TextStyle(fontSize: 24),
          ),
          Text(
            widget.song.artist,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 32),
          StreamBuilder<Duration>(
            stream: widget.audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              return Slider(
                min: 0.0,
                max: widget.audioPlayer.duration?.inMilliseconds.toDouble() ?? 0.0,
                value: position.inMilliseconds.toDouble(),
                onChanged: (value) {
                  widget.audioPlayer.seek(Duration(milliseconds: value.toInt()));
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
                onPressed: () {}, 
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
                onPressed: () {}, 
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