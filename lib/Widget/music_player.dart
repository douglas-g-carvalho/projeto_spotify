import 'dart:core';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicPlayer extends ChangeNotifier {
  bool loop = false;

  Duration musica = Duration.zero;

  final Set<String> artistName = {};
  final Set<String> artistImage = {};
  final Set<String> songList = {};

  final List<String> descriptionList = [];
  final List<String> imageList = [];

  final Map<String, AudioSource> mapSongURL = {};
  final Map<String, Duration> mapDuration = {};

  String actualSong = '';

  int songIndex = 0;

  final player = AudioPlayer();

  Widget progressBar(double width, Duration musicTime) {
    return SizedBox(
      width: width,
      child: StreamBuilder(
        stream: player.positionStream,
        builder: (context, data) {
          musica = data.data ?? Duration.zero;
          if (musica.inSeconds == (musicTime.inSeconds - 1)) {
            if (loop == true && player.playing) {
              player.seek(Duration.zero);
            }
          }
          return ProgressBar(
            progress: musica,
            total: musicTime - const Duration(seconds: 1),
            buffered: player.bufferedPosition,
            bufferedBarColor: Colors.grey,
            baseBarColor: Colors.white,
            thumbColor: Colors.green[700],
            thumbRadius: 7,
            timeLabelTextStyle: const TextStyle(color: Colors.white),
            progressBarColor: Colors.green[700],
            onSeek: (duration) async {
              await player.seek(duration);
            },
          );
        },
      ),
    );
  }

  Future<void> getUrlMusic(String musicName, String nameArtist) async {
    actualSong = musicName;

    int indexVideos = 0;
    final yt = YoutubeExplode();
    for (int index = 0; index < 20; index++) {
      final video = (await yt.search.search(
          filter: TypeFilters.video,
          "$musicName $nameArtist music"))[indexVideos];

      if (video.duration == null) {
        indexVideos++;
        continue;
      }

      if (video.duration! > const Duration(minutes: 20)) {
        indexVideos++;
        continue;
      }

      final videoId = video.id.value;
      mapDuration.addAll({musicName: video.duration!});

      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioUrl = manifest.audioOnly.last.url;

      mapSongURL.addAll({musicName: AudioSource.uri(audioUrl)});
      break;
    }
    await setAudioSource(musicName);
    notifyListeners();
  }

  Future<void> setAudioSource(String musicName) async {
    actualSong = musicName;

    await player.setAudioSource(mapSongURL[musicName]!);
    notifyListeners();
  }

  Future<void> play() async {
    if (!player.playing) {
      player.play();
    } else {
      await player.pause();
    }
    notifyListeners();
  }

  Future<void> passMusic(String lado) async {
    player.stop();
    if (lado == 'Left') {
      songIndex -= 1;
    }
    if (lado == 'Right') {
      songIndex += 1;
    }
    notifyListeners();
  }
}
