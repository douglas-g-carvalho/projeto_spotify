class Music {
  Duration? duration;
  String trackId;
  String? artistName;
  String? artistImage;
  String? songName;
  String? songImage;

  Music({
    this.duration,
    required this.trackId,
    this.artistName,
    this.artistImage,
    this.songName,
    this.songImage,
  });
}
