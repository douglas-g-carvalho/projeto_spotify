import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as sptf;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import '../Utils/constants.dart';
import '../Models/new_play_info.dart';

class PlayMusic extends StatefulWidget {
  final String trackId;
  const PlayMusic({super.key, required this.trackId});

  @override
  State<PlayMusic> createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic> {
  final player = AudioPlayer();
  late ConcatenatingAudioSource playlist;
  List<AudioSource> songURL = [];
  bool allLoad = false;

  NewPlayInfo newPlayInfo = NewPlayInfo(
    songList: {},
    imageList: [],
    newDurationMusic: {},
    musica: const Duration(seconds: 0),
    loading: false,
  );

  Future<void> play() async {
    setState(() => newPlayInfo.loading = true);
    if (!player.playing) {
      setState(() => newPlayInfo.loading = false);
      await player.play();
    } else {
      await player.pause();
      setState(() => newPlayInfo.loading = false);
    }
  }

  Future<void> getUrlMusic() async {
    for (String musicName in newPlayInfo.songList!) {
      int indexVideos = 0;
      final yt = YoutubeExplode();
      for (int index = 0; index < 20; index++) {
        final video = (await yt.search.search(
            filter: TypeFilters.video,
            "$musicName ${newPlayInfo.artistName}"))[indexVideos];

        if (video.duration! > const Duration(minutes: 20)) {
          indexVideos++;
          continue;
        }

        final videoId = video.id.value;
        newPlayInfo.newDurationMusic!.addAll({musicName: video.duration!});

        var manifest = await yt.videos.streamsClient.getManifest(videoId);
        var audioUrl = manifest.audioOnly.last.url;

        songURL.add(AudioSource.uri(audioUrl));
        break;
      }
      setState(() {});
    }
    playlist = ConcatenatingAudioSource(
        useLazyPreparation: true, children: songURL);

    await player.setAudioSource(playlist,
        initialIndex: 0, initialPosition: Duration.zero);

    setState(() => allLoad = true);
  }

  Future<void> passMusic(String lado) async {
    setState(() => newPlayInfo.loading = true);
    if (lado == 'Left') {
      await player.seekToPrevious();
    }
    if (lado == 'Right') {
      await player.seekToNext();
    }
    setState(() => newPlayInfo.loading = false);
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
      });
    }).then((value) => getUrlMusic());

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
            if (allLoad)
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
      body: allLoad
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
                          .elementAtOrNull(player.currentIndex ?? 0)!),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    newPlayInfo.songList!
                            .elementAtOrNull(player.currentIndex ?? 0) ??
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
                      stream: player.positionStream,
                      builder: (context, data) {
                        newPlayInfo.musica = data.data;
                        return ProgressBar(
                          progress:
                              newPlayInfo.musica ?? const Duration(seconds: 0),
                          total: newPlayInfo.newDurationMusic?[newPlayInfo
                                  .songList!
                                  .elementAt(player.currentIndex ?? 0)] ??
                              const Duration(seconds: 0),
                          buffered: player.bufferedPosition,
                          bufferedBarColor: Colors.grey,
                          baseBarColor: Colors.white,
                          thumbColor: Colors.green,
                          thumbRadius: 7,
                          timeLabelTextStyle:
                              const TextStyle(color: Colors.white),
                          progressBarColor: Colors.green[900],
                          onSeek: (duration) async {
                            await player.seek(duration);
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
                          await passMusic('Left');
                        },
                        child: Icon(
                          player.hasPrevious
                              ? Icons.arrow_circle_left_outlined
                              : Icons.arrow_circle_left,
                          size: width * 0.14,
                          color: player.hasPrevious ? Colors.white : Colors.red,
                        ),
                      ),
                      Stack(
                        children: [
                          TextButton(
                            onPressed: () async {
                              await play();
                            },
                            child: Icon(
                              player.playing
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
                          await passMusic('Right');
                        },
                        child: Icon(
                          player.hasNext
                              ? Icons.arrow_circle_right_outlined
                              : Icons.arrow_circle_right,
                          size: width * 0.14,
                          color: player.hasNext ? Colors.white : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading ${newPlayInfo.songList!.isEmpty ? '' : '(${((songURL.length / newPlayInfo.songList!.length) * 100).round()} %)'}',
                    style:
                        TextStyle(color: Colors.white, fontSize: width * 0.08),
                  ),
                  SizedBox(height: height * 0.03),
                  SizedBox(
                      width: width * 0.2,
                      height: height * 0.1,
                      child:
                          const CircularProgressIndicator(color: Colors.green)),
                ],
              ),
            ),
    );
  }
}
