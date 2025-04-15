import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

part "audio_player_event.dart";
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _durationSubscription;

  AudioPlayerBloc() : super(AudioPlayerInitial()) {
    on<PlaySongEvent>(_onPlaySong);
    on<PauseSongEvent>(_onPauseSong);
    on<ResumeSongEvent>(_onResumeSong);
    on<StopSongEvent>(_onStopSong);
    on<SeekSongEvent>(_onSeekSong);
    on<SetShuffleEvent>(_onSetShuffle);
    on<NextSongEvent>(_onNextSong);
    on<PreviousSongEvent>(_onPreviousSong);

    _setupDurationStream();
  }

  void _setupDurationStream() {
    _durationSubscription =
        Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      _player.positionStream,
      _player.playbackEventStream,
      (position, playbackEvent) => DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    ).listen((durationState) {
      if (state is AudioPlayerPlaying) {
        emit(AudioPlayerPlaying(
          durationState.progress,
          durationState.buffered,
          durationState.total,
          (state as AudioPlayerPlaying).isShuffle,
          (state as AudioPlayerPlaying).songUrl,
        ));
      } else if (state is AudioPlayerPaused) {
        emit(AudioPlayerPaused(
          durationState.progress,
          durationState.buffered,
          durationState.total,
          (state as AudioPlayerPaused).isShuffle,
          (state as AudioPlayerPaused).songUrl,
        ));
      }
    });
  }

  Future<void> _onPlaySong(
      PlaySongEvent event, Emitter<AudioPlayerState> emit) async {
    emit(AudioPlayerLoading());
    try {
      await _player.setUrl(event.songUrl);
      await _player.play();
      emit(AudioPlayerPlaying(
          Duration.zero, Duration.zero, null, false, event.songUrl));
    } catch (e) {
      emit(AudioPlayerError('Failed to play song: $e'));
    }
  }

  Future<void> _onPauseSong(
      PauseSongEvent event, Emitter<AudioPlayerState> emit) async {
    await _player.pause();
    if (state is AudioPlayerPlaying) {
      final currentState = state as AudioPlayerPlaying;
      emit(AudioPlayerPaused(
        currentState.progress,
        currentState.buffered,
        currentState.total,
        currentState.isShuffle,
        currentState.songUrl,
      ));
    }
  }

  Future<void> _onResumeSong(
      ResumeSongEvent event, Emitter<AudioPlayerState> emit) async {
    await _player.play();
    if (state is AudioPlayerPaused) {
      final currentState = state as AudioPlayerPaused;
      emit(AudioPlayerPlaying(
        currentState.progress,
        currentState.buffered,
        currentState.total,
        currentState.isShuffle,
        currentState.songUrl,
      ));
    }
  }

  Future<void> _onStopSong(
      StopSongEvent event, Emitter<AudioPlayerState> emit) async {
    await _player.stop();
    emit(AudioPlayerStopped());
  }

  Future<void> _onSeekSong(
      SeekSongEvent event, Emitter<AudioPlayerState> emit) async {
    await _player.seek(event.position);
  }

  Future<void> _onSetShuffle(
      SetShuffleEvent event, Emitter<AudioPlayerState> emit) async {
    if (state is AudioPlayerPlaying) {
      final currentState = state as AudioPlayerPlaying;
      emit(AudioPlayerPlaying(
        currentState.progress,
        currentState.buffered,
        currentState.total,
        event.isShuffle,
        currentState.songUrl,
      ));
    } else if (state is AudioPlayerPaused) {
      final currentState = state as AudioPlayerPaused;
      emit(AudioPlayerPaused(
        currentState.progress,
        currentState.buffered,
        currentState.total,
        event.isShuffle,
        currentState.songUrl,
      ));
    }
  }

  Future<void> _onNextSong(
      NextSongEvent event, Emitter<AudioPlayerState> emit) async {
    // Logic for next song can be added here based on song list
  }

  Future<void> _onPreviousSong(
      PreviousSongEvent event, Emitter<AudioPlayerState> emit) async {
    // Logic for previous song can be added here based on song list
  }

  @override
  Future<void> close() {
    _durationSubscription?.cancel();
    _player.dispose();
    return super.close();
  }
}

class DurationState {
  final Duration progress;
  final Duration buffered;
  final Duration? total;

  DurationState({required this.progress, required this.buffered, this.total});
}
