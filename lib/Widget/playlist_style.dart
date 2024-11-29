import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as sptf;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Utils/constants.dart';
import '../Models/new_play_info.dart';
import 'whats_playing.dart';

class PlaylistStyle extends StatefulWidget {
  final String trackId;
  const PlaylistStyle({super.key, required this.trackId});

  @override
  State<PlaylistStyle> createState() => _PlaylistStyleState();
}

class _PlaylistStyleState extends State<PlaylistStyle> {
  final player = AudioPlayer();

  NewPlayInfo newPlayInfo = NewPlayInfo(
    songList: {},
    imageList: [],
    descriptionList: [],
    newUrlMusic: {},
    newDurationMusic: {},
    loading: false,
    otherMusic: false,
  );

  Future<void> playBottom(String musicName, String artistName,
      [bool? newMusic]) async {
    if (newPlayInfo.currentSong != null) {
      setState(() => newPlayInfo.loading = true);
      await getUrlMusic(musicName, artistName);

      if (newMusic == true) {
        player.stop();

        setState(() {
          newPlayInfo.loading = true;
          newPlayInfo.otherMusic = true;
        });

        await player.play(newPlayInfo.newUrlMusic![musicName]!);

        setState(() {
          newPlayInfo.loading = false;
          newPlayInfo.otherMusic = false;
        });
      } else if (player.state == PlayerState.stopped ||
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
        // newPlayInfo.durationList!.add(video.duration!);
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
    final credentials =
        sptf.SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = sptf.SpotifyApi(credentials);

    spotify.playlists.get(widget.trackId).then((value) {
      newPlayInfo.artistName = value.name!;
      newPlayInfo.artistImage = value.images!.first.url!;

      value.tracks?.itemsNative?.forEach((value) {
        newPlayInfo.songList!.add(value['track']['name']);
        newPlayInfo.imageList!.add(value['track']['album']['images'][0]['url']);
        newPlayInfo.descriptionList!.add(value['track']['artists'][0]['name']);
      });

      setState(() {});
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
        title: Text(
          newPlayInfo.artistName ?? '',
          style: TextStyle(color: Colors.white, fontSize: width * 0.055),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
        padding: const EdgeInsets.all(5),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            ListView.separated(
              itemCount: newPlayInfo.songList!.length,
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: height * 0.01),
              itemBuilder: (BuildContext context, int index) {
                return newPlayInfo.songList!.isNotEmpty
                    ? Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: width * 0.05),
                            ),
                          ),
                          SizedBox(width: width * 0.02),
                          SizedBox(
                              width: width * 0.20,
                              height: height * 0.10,
                              child:
                                  Image.network(newPlayInfo.imageList![index])),
                          SizedBox(width: width * 0.02),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: index < 9
                                    ? width * 0.50
                                    : index < 99
                                        ? width * 0.47
                                        : width * 0.45,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    newPlayInfo.songList!.elementAt(index),
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: index < 9
                                    ? width * 0.50
                                    : index < 99
                                        ? width * 0.47
                                        : width * 0.45,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    newPlayInfo.descriptionList!
                                        .elementAt(index),
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                            ),
                            onPressed: () async {
                              if (newPlayInfo.currentSong != index &&
                                  player.state == PlayerState.playing) {
                                newPlayInfo.currentSong = index;
                                await playBottom(
                                    newPlayInfo.songList!
                                        .elementAt(newPlayInfo.currentSong!),
                                    newPlayInfo.descriptionList!
                                        .elementAt(newPlayInfo.currentSong!),
                                    true);
                              } else {
                                if (newPlayInfo.currentSong != index) {
                                  setState(() => newPlayInfo.otherMusic = true);
                                }
                                newPlayInfo.currentSong = index;
                                await playBottom(
                                  newPlayInfo.songList!
                                      .elementAt(newPlayInfo.currentSong!),
                                  newPlayInfo.descriptionList!
                                      .elementAt(newPlayInfo.currentSong!),
                                );
                                setState(() => newPlayInfo.otherMusic = false);
                              }
                              setState(() {});
                            },
                            child: Stack(
                              children: [
                                if (newPlayInfo.loading == false ||
                                    newPlayInfo.currentSong != index)
                                  Icon(
                                    (player.state == PlayerState.playing &&
                                            newPlayInfo.currentSong == index)
                                        ? Icons.pause_circle
                                        : Icons.play_circle,
                                    color: Colors.green,
                                    size: (width + height) * 0.04,
                                  ),
                                if (newPlayInfo.loading == true &&
                                    newPlayInfo.currentSong == index)
                                  SizedBox(
                                    width: ((width + height) * 0.03),
                                    height: ((width + height) * 0.03),
                                    child: const CircularProgressIndicator(
                                        color: Colors.green),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const Placeholder(color: Colors.transparent);
              },
            ),
            if (player.state != PlayerState.stopped)
              Positioned(
                bottom: 0,
                child: WhatsPlaying(
                  nameMusic:
                      newPlayInfo.songList!.elementAt(newPlayInfo.currentSong!),
                  imageMusic: newPlayInfo.imageList![newPlayInfo.currentSong!],
                  descriptionMusic: newPlayInfo.descriptionList!
                      .elementAt(newPlayInfo.currentSong!),
                  playBottom: playBottom,
                  player: player,
                  otherMusic: newPlayInfo.otherMusic!,
                  duration: newPlayInfo.newDurationMusic![newPlayInfo.songList!
                          .elementAt(newPlayInfo.currentSong!)] ??
                      const Duration(seconds: 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
