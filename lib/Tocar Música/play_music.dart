import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Geral/Constants/constants.dart';
import '../Mixes Mais Ouvidos/Componentes/mixes.dart';
import '../models/music.dart';

class PlayMusic extends StatefulWidget {
  const PlayMusic({super.key});

  @override
  State<PlayMusic> createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic> {
  final player = AudioPlayer();
  Music music = Music(trackId: '6MUl1xbEStdt9r3JJAW6dF');

  @override
  void initState() {
    final credentials =
        SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = SpotifyApi(credentials);
    spotify.tracks.get(music.trackId).then((track) async {
      String? tempSongName = track.name;
      if (tempSongName != null) {
        music.songName = tempSongName;
        music.artistName = track.artists?.first.name ?? "";
        String? image = track.album?.images?.first.url;
        if (image != null) {
          music.songImage = image;
        }
      }
      music.artistImage = track.artists?.first.images?.first.url;
      setState(() {});
      final yt = YoutubeExplode();
      final video =
          (await yt.search.search("$tempSongName ${music.artistName ?? ""}"))
              .first;

      final videoId = video.id.value;
      music.duration = video.duration;

      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioUrl = manifest.audioOnly.last.url;
      player.play(UrlSource(audioUrl.toString()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Música',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                '${music.songName}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          SizedBox(
            width: 275,
            height: 275,
            child: Mixes().mixes(teste: music.songImage),
          ),
          SizedBox(
            width: 400,
            child: StreamBuilder(
              stream: player.onPositionChanged,
              builder: (context, data) {
                return ProgressBar(
                  progress: data.data ?? const Duration(seconds: 0),
                  total:
                      music.duration ?? const Duration(minutes: 2, seconds: 40),
                  bufferedBarColor: Colors.white38,
                  baseBarColor: Colors.white10,
                  thumbColor: Colors.white,
                  timeLabelTextStyle: const TextStyle(color: Colors.white),
                  progressBarColor: Colors.white,
                  onSeek: (duration) {
                    player.seek(duration);
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
            onPressed: () async {
              if (player.state == PlayerState.playing) {
                await player.pause();
              } else {
                await player.resume();
              }
              setState(() {});
            },
            child: Icon(
              player.state == PlayerState.playing
                  ? Icons.pause
                  : Icons.play_arrow,
              size: 80,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
