class Playlist {
  String trackId;
  String? artistName;
  String? artistImage;
  String? songName;
  String? songImage;
  String? description;
  int? totalSongs;

  Playlist({
    required this.trackId,
    this.artistName,
    this.artistImage,
    this.songName,
    this.songImage,
    this.description,
    this.totalSongs,
  });
}
