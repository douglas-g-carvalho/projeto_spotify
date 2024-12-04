import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as sptf;
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Utils/constants.dart';
import '../Models/new_play_info.dart';

class PlayPlaylist extends StatefulWidget {
  final String trackId;
  const PlayPlaylist({super.key, required this.trackId});

  @override
  State<PlayPlaylist> createState() => _PlayPlaylistState();
}

class _PlayPlaylistState extends State<PlayPlaylist> {
  final player = AudioPlayer();

  NewPlayInfo newPlayInfo = NewPlayInfo(
    songList: {},
    imageList: [],
    newUrlMusic: {},
    newDurationMusic: {},
    pass: 0,
    reiniciar: 0,
    musica: const Duration(seconds: 0),
    loading: false,
  );

  Future<void> play(
    String musicName,
    String artistName,
  ) async {
    setState(() => newPlayInfo.loading = true);
    await getUrlMusic(musicName, artistName);

    if (player.state == PlayerState.stopped ||
        player.state == PlayerState.paused) {
      setState(() => newPlayInfo.loading = true);

      await player.play(newPlayInfo.newUrlMusic![musicName]!);

      setState(() => newPlayInfo.loading = false);
    } else {
      await player.pause();
      setState(() => newPlayInfo.loading = false);
    }
    setState(() {});
  }

  Future<void> getUrlMusic(String musicName, String artistName) async {
    if (!newPlayInfo.newUrlMusic!.containsKey(musicName)) {
      int indexVideos = 0;
      final yt = YoutubeExplode();
      for (int index = 0; index < 20; index++) {
        final video = (await yt.search.search(
            filter: TypeFilters.video, "$musicName $artistName"))[indexVideos];

        if (video.duration! > const Duration(minutes: 20)) {
          indexVideos++;
          continue;
        }

        final videoId = video.id.value;
        newPlayInfo.newDurationMusic!.addAll({musicName: video.duration!});

        var manifest = await yt.videos.streamsClient.getManifest(videoId);
        var audioUrl = manifest.audioOnly.last.url;

        newPlayInfo.newUrlMusic!
            .addAll({musicName: UrlSource(audioUrl.toString())});
        setState(() {});
        break;
      }
    }
  }

  @override
  void initState() {
    newPlayInfo.trackId = widget.trackId;
    final credentials =
        sptf.SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = sptf.SpotifyApi(credentials);

    spotify.playlists.get(newPlayInfo.trackId!).then((value) {
      newPlayInfo.artistName = value.name;
      newPlayInfo.artistImage = value.images?.first.url;
      newPlayInfo.totalSongs = value.tracks?.total;

      value.tracks?.itemsNative?.forEach((value) {
        newPlayInfo.songList!.add(value['track']['name']);
        newPlayInfo.imageList!.add(value['track']['album']['images'][0]['url']);
        setState(() {});
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            if (newPlayInfo.songList!.isNotEmpty)
              SizedBox(
                width: width * 0.14,
                height: height * 0.14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.network(newPlayInfo.artistImage!),
                ),
              ),
            SizedBox(width: width * 0.02),
            Expanded(
              child: Text(
                newPlayInfo.artistName ?? '',
                style: TextStyle(color: Colors.white, fontSize: width * 0.065),
              ),
            ),
          ],
        ),
      ),
      body: newPlayInfo.songList!.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.15),
                  SizedBox(
                    width: size.width * 1,
                    height: size.height * 0.4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Image.network(newPlayInfo.imageList!
                          .elementAtOrNull(newPlayInfo.pass!)!),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    newPlayInfo.songList!.elementAtOrNull(newPlayInfo.pass!) ??
                        '',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.07,
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.80,
                    child: StreamBuilder(
                      stream: player.onPositionChanged,
                      builder: (context, data) {
                        newPlayInfo.musica = data.data;
                        if (newPlayInfo.reiniciar != newPlayInfo.pass) {
                          newPlayInfo.reiniciar = newPlayInfo.pass;
                          newPlayInfo.musica = const Duration(seconds: 0);
                        }

                        return ProgressBar(
                          progress:
                              newPlayInfo.musica ?? const Duration(seconds: 0),
                          total: newPlayInfo.newDurationMusic?[newPlayInfo
                                  .songList!
                                  .elementAt(newPlayInfo.pass!)] ??
                              const Duration(seconds: 0),
                          bufferedBarColor: Colors.grey,
                          baseBarColor: Colors.white,
                          thumbColor: Colors.green,
                          thumbRadius: 7,
                          timeLabelTextStyle:
                              const TextStyle(color: Colors.white),
                          progressBarColor: Colors.green[900],
                          onSeek: (duration) {
                            player.seek(duration);
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (newPlayInfo.pass != 0) {
                            await player.pause();
                            newPlayInfo.pass = newPlayInfo.pass! - 1;
                            newPlayInfo.musica = const Duration(seconds: 0);
                            setState(() {});
                          }
                        },
                        child: Icon(
                          newPlayInfo.pass == 0
                              ? Icons.arrow_circle_left_outlined
                              : Icons.arrow_circle_left,
                          size: width * 0.14,
                          color: Colors.white,
                        ),
                      ),
                      Stack(
                        children: [
                          TextButton(
                            onPressed: () async {
                              await play(
                                  newPlayInfo.songList!
                                      .elementAt(newPlayInfo.pass!),
                                  newPlayInfo.artistName!);
                            },
                            child: Icon(
                              player.state == PlayerState.playing
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              size: (size.width + size.height) * 0.08,
                              color: newPlayInfo.loading!
                                  ? Colors.transparent
                                  : Colors.white,
                            ),
                          ),
                          if (newPlayInfo.loading!)
                            Positioned(
                              right: size.width * 0.05,
                              bottom: size.height * 0.021,
                              child: SizedBox(
                                width: (size.width + size.height) * 0.065,
                                height: (size.width + size.height) * 0.065,
                                child: const CircularProgressIndicator(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                      TextButton(
                        onPressed: () async {
                          if (newPlayInfo.pass !=
                              newPlayInfo.songList!.length - 1) {
                            await player.pause();
                            newPlayInfo.pass = newPlayInfo.pass! + 1;
                            newPlayInfo.musica = const Duration(seconds: 0);
                            setState(() {});
                          }
                        },
                        child: Icon(
                          newPlayInfo.pass == newPlayInfo.songList!.length - 1
                              ? Icons.arrow_circle_right_outlined
                              : Icons.arrow_circle_right,
                          size: width * 0.14,
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
