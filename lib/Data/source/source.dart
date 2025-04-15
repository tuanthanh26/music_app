import 'dart:convert';
import 'package:flutter/services.dart';

import '../model/song.dart';
import 'package:http/http.dart' as http;

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}

//lay du lieu tu internet
//flutter pub add http
class remoteDataSource implements DataSource {
  @override
  // bất đồng bộ Future ở trạng thái chờ
  Future<List<Song>?> loadData() async {
    final url = 'https://tuanthanhfast4g.site/Manager/MusicAPI/music.json';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    /*---------------------------------*/
    if (response.statusCode == 200) {
      // chuyen doi uft8 de doc ki tu tieng viet
      final bodyContent = utf8.decode(response.bodyBytes);
      var songWrapper = jsonDecode(bodyContent) as Map;
      var songList = songWrapper['songs'] as List;
      List<Song> songs = songList.map((song) => Song.fromJson(song)).toList();
      return songs;
    } else {
      return null;
    }
  }
}

//lay du lieu tu local
class localDatasource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    final String response = await rootBundle.loadString('assets/song.json');
    final jsonBody = jsonDecode(response) as Map;
    final songList = jsonBody['songs'] as List;
    List<Song> songs = songList.map((song) => Song.fromJson(song)).toList();
    return songs;
  }
}
