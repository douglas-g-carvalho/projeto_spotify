import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Geral/Constants/constants.dart';
import '../Mixes Mais Ouvidos/Componentes/mixes.dart';
import '../models/playlist.dart' as playlist;

class PlayPlaylist extends StatefulWidget {
  final String trackId;
  const PlayPlaylist({super.key, required this.trackId});

  @override
  State<PlayPlaylist> createState() => _PlayPlaylistState();
}

class _PlayPlaylistState extends State<PlayPlaylist> {
  final player = AudioPlayer();
  late playlist.Playlist music = playlist.Playlist(trackId: widget.trackId);

  Set<String> songList = {};
  List<String> imageList = [];
  List<Duration> durationList = [];
  List<UrlSource> songURL = [];
  int pass = 0;
  int reiniciar = 0;
  Duration? musica = const Duration(seconds: 0);

  @override
  void initState() {
    final credentials =
        SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = SpotifyApi(credentials);

    spotify.playlists.get(music.trackId).then((value) async {
      music.artistName = value.name;
      music.artistImage = value.images?.first.url;
      music.totalSongs = value.tracks?.total;

      value.tracks?.itemsNative?.forEach((value) {
        songList.add(value['track']['name']);
        imageList.add(value['track']['album']['images'][0]['url']);
      });
    }).then((value) async {
      for (int index = 0; index != songList.length; index++) {
        final yt = YoutubeExplode();
        final video = (await yt.search.search(
                "${songList.elementAt(index)} ${music.artistName ?? ""}"))
            .first;

        final videoId = video.id.value;
        durationList.add(video.duration!);

        var manifest = await yt.videos.streamsClient.getManifest(videoId);
        var audioUrl = manifest.audioOnly.last.url;

        songURL.add(UrlSource(audioUrl.toString()));
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Mixes().mixes(teste: music.artistImage),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                music.artistName ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: songList.isNotEmpty
          ? Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 275,
                    height: 275,
                    child:
                        Mixes().mixes(teste: imageList.elementAtOrNull(pass)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    songList.elementAtOrNull(pass) ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.80,
                    child: StreamBuilder(
                        stream: player.onPositionChanged,
                        builder: (context, data) {
                          musica = data.data;
                          if (reiniciar != pass) {
                            reiniciar = pass;
                            musica = const Duration(seconds: 0);
                          }
                          // criar uma variavel pra substituir o data e deixar global
                          return ProgressBar(
                            progress: musica ?? const Duration(seconds: 0),
                            total: durationList[pass],
                            bufferedBarColor: Colors.white38,
                            baseBarColor: Colors.white10,
                            thumbColor: Colors.white,
                            timeLabelTextStyle:
                                const TextStyle(color: Colors.white),
                            progressBarColor: Colors.white,
                            onSeek: (duration) {
                              player.seek(duration);
                            },
                          );
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (pass != 0) {
                            pass--;
                            musica = const Duration(seconds: 0);
                            setState(() {});
                          }
                        },
                        child: Icon(
                          pass == 0
                              ? Icons.arrow_circle_left_outlined
                              : Icons.arrow_circle_left,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (player.state == PlayerState.stopped ||
                              player.state == PlayerState.paused) {
                            await player.play(songURL[pass]);
                          } else {
                            await player.pause();
                          }

                          setState(() {});
                        },
                        child: Icon(
                          player.state == PlayerState.playing
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (pass != songList.length - 1) {
                            pass++;
                            musica = const Duration(seconds: 0);
                            setState(() {});
                          }
                        },
                        child: Icon(
                          pass == songList.length - 1
                              ? Icons.arrow_circle_right_outlined
                              : Icons.arrow_circle_right,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.green)),
    );
  }
}
