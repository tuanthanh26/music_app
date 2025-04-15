part of 'audio_player_bloc.dart';

abstract class AudioPlayerState {}

class AudioPlayerInitial extends AudioPlayerState {}

class AudioPlayerLoading extends AudioPlayerState {}

class AudioPlayerPlaying extends AudioPlayerState {
  final Duration progress;
  final Duration buffered;
  final Duration? total;
  final bool isShuffle;
  final String songUrl;
  AudioPlayerPlaying(this.progress, this.buffered, this.total, this.isShuffle, this.songUrl);
}

class AudioPlayerPaused extends AudioPlayerState {
  final Duration progress;
  final Duration buffered;
  final Duration? total;
  final bool isShuffle;
  final String songUrl;
  AudioPlayerPaused(this.progress, this.buffered, this.total, this.isShuffle, this.songUrl);
}

class AudioPlayerStopped extends AudioPlayerState {}

class AudioPlayerError extends AudioPlayerState {
  final String message;
  AudioPlayerError(this.message);
}