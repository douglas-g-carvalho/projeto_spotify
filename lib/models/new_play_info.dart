import 'package:audioplayers/audioplayers.dart';

class NewPlayInfo {
  String? trackId;
  String? artistName;
  String? artistImage;
  String? songName;
  String? songImage;
  String? description;

  int? totalSongs;
  int? pass;
  int? reiniciar;
  int? currentSong;

  Set<String>? songList;

  List<String>? imageList;
  List<Duration>? durationList;
  List<UrlSource>? songURL;
  List<String>? descriptionList;

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
    this.descriptionList,
    this.durationList,
    this.imageList,
    this.loading,
    this.musica,
    this.otherMusic,
    this.pass,
    this.reiniciar,
    this.songList,
    this.songURL,
  });
}
