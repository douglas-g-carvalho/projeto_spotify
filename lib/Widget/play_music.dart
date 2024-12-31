import 'package:flutter/material.dart';
import 'package:projeto_spotify/Widget/music_player.dart';
import 'package:spotify/spotify.dart' as sptf;

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import '../Utils/constants.dart';

class PlayMusic extends StatefulWidget {
  final String trackId;
  const PlayMusic({super.key, required this.trackId});

  @override
  State<PlayMusic> createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic> {
  final musicPlayer = MusicPlayer();

  bool allLoad = false;
  bool loading = false;
  Duration musica = const Duration(seconds: 0);

  @override
  void initState() {
    final credentials =
        sptf.SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = sptf.SpotifyApi(credentials);

    spotify.playlists.get(widget.trackId).then((value) {
      musicPlayer.artistName.add(value.name!);
      musicPlayer.artistImage.add(value.images!.first.url!);

      value.tracks?.itemsNative?.forEach((value) {
        if (musicPlayer.songList.length <= 10) {
          musicPlayer.songList.add(value['track']['name']);
          musicPlayer.imageList
              .add(value['track']['album']['images'][0]['url']);
        }
        setState(() {});
      });
    }).then((value) => setState(() => allLoad = true));

    super.initState();
  }

  @override
  void dispose() {
    musicPlayer.player.dispose();
    super.dispose();
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
                  child: Image.network(
                      musicPlayer.artistImage.elementAtOrNull(0) ?? ''),
                ),
              ),
            SizedBox(width: width * 0.01),
            Expanded(
              child: Text(
                musicPlayer.artistName.elementAtOrNull(0) ?? '',
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
                  SizedBox(height: size.height * 0.07),
                  SizedBox(
                    width: size.width * 1,
                    height: size.height * 0.4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Image.network(musicPlayer.imageList
                          .elementAtOrNull(musicPlayer.songIndex)!),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    musicPlayer.songList
                            .elementAtOrNull(musicPlayer.songIndex) ??
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
                      stream: musicPlayer.player.positionStream,
                      builder: (context, data) {
                        musica = data.data ?? Duration.zero;
                        return ProgressBar(
                          progress: musica,
                          total: musicPlayer.mapDuration[musicPlayer.songList
                                  .elementAt(musicPlayer.songIndex)] ??
                              Duration.zero,
                          buffered: musicPlayer.player.bufferedPosition,
                          bufferedBarColor: Colors.grey,
                          baseBarColor: Colors.white,
                          thumbColor: Colors.green,
                          thumbRadius: 7,
                          timeLabelTextStyle:
                              const TextStyle(color: Colors.white),
                          progressBarColor: Colors.green[900],
                          onSeek: (duration) async {
                            await musicPlayer.player.seek(duration);
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
                          if (musicPlayer.songIndex != 0) {
                            setState(() => loading = true);
                            await musicPlayer.passMusic('Left');
                            setState(() => loading = false);
                          }
                        },
                        child: Icon(
                          musicPlayer.songIndex != 0
                              ? Icons.arrow_circle_left_outlined
                              : Icons.arrow_circle_left,
                          size: width * 0.14,
                          color: musicPlayer.songIndex != 0
                              ? Colors.white
                              : Colors.red,
                        ),
                      ),
                      Stack(
                        children: [
                          TextButton(
                            onPressed: () async {
                              setState(() => loading = true);

                              // checa se a música existe no mapSongURL
                              if (!musicPlayer.mapSongURL.containsKey(
                                  musicPlayer.songList
                                      .elementAt(musicPlayer.songIndex))) {
                                await musicPlayer.getUrlMusic(
                                    musicPlayer.songList
                                        .elementAt(musicPlayer.songIndex),
                                    musicPlayer.artistName.elementAt(0));
                                // checa se a música sendo tocada é a nova;
                              } else if (musicPlayer.actualSong !=
                                  musicPlayer.songList
                                      .elementAt(musicPlayer.songIndex)) {
                                await musicPlayer.setAudioSource(musicPlayer
                                    .songList
                                    .elementAt(musicPlayer.songIndex));
                              }

                              await musicPlayer.play();
                              setState(() => loading = false);
                            },
                            child: Icon(
                              musicPlayer.player.playing
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              size: (size.width + size.height) * 0.08,
                              color:
                                  loading ? Colors.transparent : Colors.white,
                            ),
                          ),
                          if (loading)
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
                          if (musicPlayer.songIndex !=
                              musicPlayer.songList.length - 1) {
                            setState(() => loading = true);
                            await musicPlayer.passMusic('Right');
                            setState(() => loading = false);
                          }
                        },
                        child: Icon(
                          musicPlayer.songIndex !=
                                  musicPlayer.songList.length - 1
                              ? Icons.arrow_circle_right_outlined
                              : Icons.arrow_circle_right,
                          size: width * 0.14,
                          color: musicPlayer.songIndex !=
                                  musicPlayer.songList.length - 1
                              ? Colors.white
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: SizedBox(
                  width: width * 0.2,
                  height: height * 0.1,
                  child: const CircularProgressIndicator(color: Colors.green)),
            ),
    );
  }
}
