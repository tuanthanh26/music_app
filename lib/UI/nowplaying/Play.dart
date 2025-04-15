import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:songapp/Data/model/song.dart';
import 'audio_player_bloc.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({super.key, required this.songs, required this.playingSong});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool isFavorite = false;
  late int _selectedItemIndex;
  late Song _song;
  List<int> _playedSongsStack = [];

  @override
  void initState() {
    super.initState();
    _song = widget.playingSong;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioPlayerBloc()..add(PlaySongEvent(_song.source)),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Now Playing', style: TextStyle(color: _getTextColor())),
          trailing: IconButton(
            onPressed: () => setState(() => isFavorite = !isFavorite),
            icon: Icon(Icons.favorite,
                color: isFavorite ? Colors.red : _getTextColor()),
          ),
          backgroundColor: _isDarkMode() ? Colors.black : Colors.white,
        ),
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_song.album,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  const Text('_________'),
                  const SizedBox(height: 20),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0)
                        .animate(_animationController),
                    child: _buildAlbumArt(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.share_outlined),
                            color: Theme.of(context).colorScheme.primary),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SelectableText(_song.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              SelectableText('Singer: ${_song.artist}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        _progressBar(),
                        const SizedBox(height: 10),
                        _mediaButtons(),
                        const SizedBox(height: 10),
                        _mediaSlideButtons(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isDarkMode() =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  Color _getTextColor() => _isDarkMode() ? Colors.white : Colors.black;

  Widget _buildAlbumArt() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.white38.withOpacity(0.6),
              blurRadius: 50,
              spreadRadius: 15)
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/download.png',
          image: _song.image,
          width: screenWidth - 64,
          height: (screenWidth - 64) * 1.0,
          fit: BoxFit.cover,
          imageErrorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/download.png',
              width: screenWidth - 64,
              height: (screenWidth - 64) * 1.0,
              fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _progressBar() {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        Duration progress = Duration.zero;
        Duration total = Duration.zero;
        if (state is AudioPlayerPlaying) {
          progress = state.progress;
          total = state.total ?? Duration.zero;
        } else if (state is AudioPlayerPaused) {
          progress = state.progress;
          total = state.total ?? Duration.zero;
        }
        return Column(
          children: [
            Slider(
              min: 0,
              max: total.inMilliseconds.toDouble(),
              value: progress.inMilliseconds
                  .toDouble()
                  .clamp(0.0, total.inMilliseconds.toDouble()),
              onChanged: (value) => context
                  .read<AudioPlayerBloc>()
                  .add(SeekSongEvent(Duration(milliseconds: value.toInt()))),
              activeColor: Colors.pinkAccent,
              inactiveColor: Colors.grey,
            ),
            Text("${_formatDuration(progress)} / ${_formatDuration(total)}",
                style: const TextStyle(fontSize: 15, color: Colors.pinkAccent)),
          ],
        );
      },
    );
  }

  Widget _mediaButtons() {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        bool isPlaying = state is AudioPlayerPlaying;
        bool isShuffle = (state is AudioPlayerPlaying && state.isShuffle) ||
            (state is AudioPlayerPaused && state.isShuffle);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MediaButtonControl(
                function: () => context
                    .read<AudioPlayerBloc>()
                    .add(SetShuffleEvent(!isShuffle)),
                icon: Icons.shuffle,
                color: isShuffle ? Colors.pinkAccent : Colors.grey,
                size: 24),
            MediaButtonControl(
                function: _setPrevSong,
                icon: Icons.skip_previous,
                color: Colors.grey,
                size: 36),
            MediaButtonControl(
              function: () => context
                  .read<AudioPlayerBloc>()
                  .add(isPlaying ? PauseSongEvent() : ResumeSongEvent()),
              icon: isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.pinkAccent,
              size: 48,
            ),
            MediaButtonControl(
                function: _setNextSong,
                icon: Icons.skip_next,
                color: Colors.grey,
                size: 36),
            MediaButtonControl(
                function: null,
                icon: Icons.repeat,
                color: Colors.redAccent,
                size: 24),
          ],
        );
      },
    );
  }

  Widget _mediaSlideButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: _isDarkMode() ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: () {},
              icon: Icons.download_rounded,
              color: Colors.grey,
              size: 26),
          MediaButtonControl(
              function: () {},
              icon: Icons.share_outlined,
              color: Colors.grey,
              size: 26),
          MediaButtonControl(
              function: () {},
              icon: Icons.music_note,
              color: Colors.pinkAccent,
              size: 26),
          MediaButtonControl(
              function: () {},
              icon: Icons.volume_up,
              color: Colors.grey,
              size: 26),
        ],
      ),
    );
  }

  void _setNextSong() {
    _selectedItemIndex = (_selectedItemIndex + 1) % widget.songs.length;
    final nextSong = widget.songs[_selectedItemIndex];
    setState(() => _song = nextSong);
    context.read<AudioPlayerBloc>().add(PlaySongEvent(nextSong.source));
  }

  void _setPrevSong() {
    _selectedItemIndex =
        (_selectedItemIndex - 1 + widget.songs.length) % widget.songs.length;
    final prevSong = widget.songs[_selectedItemIndex];
    setState(() => _song = prevSong);
    context.read<AudioPlayerBloc>().add(PlaySongEvent(prevSong.source));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

class MediaButtonControl extends StatelessWidget {
  const MediaButtonControl(
      {super.key,
      required this.function,
      required this.icon,
      required this.size,
      required this.color});

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: function,
        icon: Icon(icon),
        iconSize: size,
        color: color ?? Theme.of(context).colorScheme.primary);
  }
}
