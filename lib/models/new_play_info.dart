class NewPlayInfo {
  String? trackId;
  String? artistName;
  String? artistImage;
  String? songName;
  String? songImage;
  String? description;

  int? totalSongs;
  int? currentSong;

  Set<String>? songList;

  List<String>? imageList;

  Map<String, Duration>? newDurationMusic;

  Duration? musica;

  bool? loading;
  bool? otherMusic;

  NewPlayInfo({
    this.trackId,
    this.artistName,
    this.artistImage,
    this.songName,
    this.songImage,
    this.description,
    this.totalSongs,
    this.currentSong,
    this.imageList,
    this.loading,
    this.newDurationMusic,
    this.musica,
    this.otherMusic,
    this.songList,
  });
}
