part of 'audio_player_bloc.dart';

abstract class AudioPlayerEvent {}

class PlaySongEvent extends AudioPlayerEvent {
  final String songUrl;

  PlaySongEvent(this.songUrl);
}

class PauseSongEvent extends AudioPlayerEvent {}

class ResumeSongEvent extends AudioPlayerEvent {}

class StopSongEvent extends AudioPlayerEvent {}

class SeekSongEvent extends AudioPlayerEvent {
  final Duration position;

  SeekSongEvent(this.position);
}

class SetShuffleEvent extends AudioPlayerEvent {
  final bool isShuffle;

  SetShuffleEvent(this.isShuffle);
}

class NextSongEvent extends AudioPlayerEvent {}

class PreviousSongEvent extends AudioPlayerEvent {}
