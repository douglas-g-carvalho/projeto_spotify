class NewPlayInfo {
  String? trackId;
  String? playlistName;
  String? artistImage;
  String? songName;
  String? songImage;

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
    this.playlistName,
    this.artistImage,
    this.songName,
    this.songImage,
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
