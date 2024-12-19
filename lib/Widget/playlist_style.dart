import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as sptf;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:just_audio/just_audio.dart';

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
  Map<int, AudioSource> mapSongURL = {};
  List<String> descriptionList = [];

  NewPlayInfo newPlayInfo = NewPlayInfo(
    songList: {},
    imageList: [],
    newDurationMusic: {},
    loading: false,
    otherMusic: false,
  );

  Future<void> playBottom([bool? newMusic]) async {
    setState(() => newPlayInfo.loading = true);

    if (newMusic == true) {
      player.stop();

      await getUrlMusic();

      setState(() {
        newPlayInfo.otherMusic = true;
      });

      await player.setAudioSource(mapSongURL[newPlayInfo.currentSong!]!,
          initialPosition: Duration.zero);

      setState(() {
        newPlayInfo.loading = false;
        newPlayInfo.otherMusic = false;
      });

      await player.play();
    } else if (!player.playing) {
      setState(() => newPlayInfo.loading = false);
      player.play();
    } else {
      await player.pause();
      setState(() => newPlayInfo.loading = false);
    }
    setState(() {});
  }

  Future<void> getUrlMusic() async {
    if (mapSongURL.containsKey(newPlayInfo.currentSong)) {
      return;
    }

    int indexVideos = 0;
    final yt = YoutubeExplode();
    for (int index = 0; index < 20; index++) {
      final video = (await yt.search.search(
              filter: TypeFilters.video,
              "${newPlayInfo.songList!.elementAt(newPlayInfo.currentSong!)} ${descriptionList.elementAt(newPlayInfo.currentSong!)} music"))[
          indexVideos];

      if (video.duration! > const Duration(minutes: 20)) {
        indexVideos++;
        continue;
      }

      final videoId = video.id.value;

      newPlayInfo.newDurationMusic!.addAll({
        newPlayInfo.songList!.elementAt(newPlayInfo.currentSong!):
            video.duration!
      });

      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioUrl = manifest.audioOnly.last.url;

      mapSongURL.addAll({newPlayInfo.currentSong!: AudioSource.uri(audioUrl)});
      setState(() {});
      break;
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
        descriptionList.add(value['track']['artists'][0]['name']);
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
                                    descriptionList
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
                              if (newPlayInfo.currentSong != index) {
                                newPlayInfo.currentSong = index;
                                await playBottom(true);
                              } else {
                                if (newPlayInfo.currentSong != index) {
                                  setState(() => newPlayInfo.otherMusic = true);
                                }
                                newPlayInfo.currentSong = index;
                                await playBottom();
                                setState(() => newPlayInfo.otherMusic = false);
                              }
                              setState(() {});
                            },
                            child: Stack(
                              children: [
                                if (newPlayInfo.loading == false ||
                                    newPlayInfo.currentSong != index)
                                  Icon(
                                    (player.playing &&
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
            if (player.currentIndex != null)
              Positioned(
                bottom: 0,
                child: WhatsPlaying(
                  nameMusic:
                      newPlayInfo.songList!.elementAt(newPlayInfo.currentSong!),
                  imageMusic: newPlayInfo.imageList![newPlayInfo.currentSong!],
                  descriptionMusic:
                      descriptionList.elementAt(newPlayInfo.currentSong!),
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
