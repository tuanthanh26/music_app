
class Song {
  // tạo 1 contructor
  // du lieu lay tu json
  Song(
      {required this.id,
      required this.title,
      required this.album,
      required this.artist,
      required this.source,
      required this.image,
      required this.duration,
      required this.favourite,
      required this.counter,
      required this.replay});

  // Hàm chuyển đổi từ JSON sang đối tượng `Song`
  factory Song.fromJson(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      album: map['album'],
      artist: map['artist'],
      source: map['source'],
      image: map['image'],
      duration: map['duration'],
      favourite: map['favorite'] == "true",
      // Chuyển đổi từ String thành bool
      counter: map['counter'],
      replay: map['replay'],
    );
  }

  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;
  bool favourite;
  int counter;
  int replay;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && album == other.album;

  @override
  int get hashCode => album.hashCode;
  //command + n
  @override
  String toString() {
    return 'Song{id: $id, title: $title, album: $album, artist: $artist, source: $source, image: $image, duration: $duration, favourite: $favourite, counter: $counter, replay: $replay}';
  }
}
