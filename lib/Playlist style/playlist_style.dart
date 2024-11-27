import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spot;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Geral/Constants/constants.dart';
import '../models/new_play_info.dart';
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
    durationList: [],
    songURL: [],
    descriptionList: [],
    loading: false,
    otherMusic: false,
   );

  // Set<String> songList = {};
  // List<String> imageList = [];
  // List<Duration> durationList = [];
  // List<UrlSource> songURL = [];
  // List<String> description = [];
// criar uma classe pra armazenar essas variaveis e as da play_playlist.dart tbm
  // String? artistName;
  // String? artistImage;

  // int? currentSong;

  // bool loading = false;
  // bool otherMusic = false;

  Future<void> playBottom([bool? newMusic]) async {
    if (newPlayInfo.currentSong != null) {
      if (newMusic == true) {
        player.stop();
        setState(() {
          newPlayInfo.loading = true;
           newPlayInfo.otherMusic = true;
        });
        await player.play( newPlayInfo.songURL![ newPlayInfo.currentSong!]);
        setState(() {
           newPlayInfo.loading = false;
           newPlayInfo.otherMusic = false;
        });
      } else if ( newPlayInfo.songURL!.elementAtOrNull( newPlayInfo.currentSong!) != null) {
        if (player.state == PlayerState.stopped ||
            player.state == PlayerState.paused) {
          setState(() =>  newPlayInfo.loading = true);
          await player.play( newPlayInfo.songURL![ newPlayInfo.currentSong!]);
          setState(() =>  newPlayInfo.loading = false);
        } else {
          await player.pause();
        }
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    final credentials =
        spot.SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = spot.SpotifyApi(credentials);

    spotify.playlists.get(widget.trackId).then((value) {
       newPlayInfo.artistName = value.name!;
       newPlayInfo.artistImage = value.images!.first.url!;

      value.tracks?.itemsNative?.forEach((value) {
         newPlayInfo.songList!.add(value['track']['name']);
         newPlayInfo.imageList!.add(value['track']['album']['images'][0]['url']);
         newPlayInfo.descriptionList!.add(value['track']['artists'][0]['name']);
      });

      setState(() {});
    }).then((value) async {
      int indexVideos = 0;
      final yt = YoutubeExplode();
      for (int index = 0; index !=  newPlayInfo.songList!.length; index++) {
        final video = (await yt.search.search(
            "${ newPlayInfo.songList!.elementAt(index)} ${ newPlayInfo.artistName ?? ""} music"))[indexVideos];

        if (video.duration! > const Duration(minutes: 20)) {
          indexVideos++;
          index--;
          continue;
        } else {
          indexVideos = 0;
        }

        final videoId = video.id.value;
         newPlayInfo.durationList!.add(video.duration!);

        var manifest = await yt.videos.streamsClient.getManifest(videoId);
        var audioUrl = manifest.audioOnly.last.url;

         newPlayInfo.songURL!.add(UrlSource(audioUrl.toString()));
        setState(() {});
      }
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
          style: const TextStyle(color: Colors.white),
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
              itemCount:  newPlayInfo.songList!.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int index) {
                return  newPlayInfo.songList!.isNotEmpty
                    ? Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                              width: width * 0.20,
                              height: height * 0.10,
                              child: Image.network( newPlayInfo.imageList![index])),
                          const SizedBox(width: 5),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: index < 9 ? width * 0.50 : width * 0.47,
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
                                width: index < 9 ? width * 0.50 : width * 0.47,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                     newPlayInfo.descriptionList!.elementAt(index),
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
                              if ( newPlayInfo.currentSong != index &&
                                  player.state == PlayerState.playing) {
                                 newPlayInfo.currentSong = index;
                                await playBottom(true);
                              } else {
                                if ( newPlayInfo.currentSong != index) {
                                  setState(() =>  newPlayInfo.otherMusic = true);
                                }
                                 newPlayInfo.currentSong = index;
                                await playBottom();
                                setState(() =>  newPlayInfo.otherMusic = false);
                              }
                              setState(() {});
                            },
                            child: Stack(
                              children: [
                                if ( newPlayInfo.loading == false ||  newPlayInfo.currentSong != index)
                                  Icon(
                                    (player.state == PlayerState.playing &&
                                             newPlayInfo.currentSong == index)
                                        ? Icons.pause_circle
                                        : Icons.play_circle,
                                    color:  newPlayInfo.songURL!.elementAtOrNull(index) !=
                                            null
                                        ? Colors.green
                                        : const Color.fromARGB(255, 75, 97, 75),
                                    size: (width + height) * 0.04,
                                  ),
                                if ( newPlayInfo.loading == true &&  newPlayInfo.currentSong == index)
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
                  nameMusic:  newPlayInfo.songList!.elementAt( newPlayInfo.currentSong!),
                  imageMusic:  newPlayInfo.imageList![ newPlayInfo.currentSong!],
                  descriptionMusic:  newPlayInfo.descriptionList!.elementAt( newPlayInfo.currentSong!),
                  playBottom: playBottom,
                  player: player,
                  otherMusic:  newPlayInfo.otherMusic!,
                  duration:  newPlayInfo.durationList![ newPlayInfo.currentSong!],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
