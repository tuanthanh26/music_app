import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:songapp/Data/model/song.dart';

import 'package:songapp/Data/repository/repository.dart';

part 'music_event.dart';
part 'music_state.dart';

class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final DefaultRepository _repository;
  MusicBloc(this._repository) : super(MusicInitial()) {
    on<LoadSongsEvent>(_onLoadSongs);
  }

  Future<void> _onLoadSongs(LoadSongsEvent event, Emitter<MusicState> emit) async {
    emit(MusicLoading());
    try {
      final songs = await _repository.loadData();
      if (songs != null) {
        emit(MusicLoaded(songs));
      } else {
        emit(MusicError('No songs found'));
      }
    } catch (e) {
      emit(MusicError('Failed to load songs: $e'));
    }
  }
}