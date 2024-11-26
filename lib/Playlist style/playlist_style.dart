import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spot;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Geral/Constants/constants.dart';
import 'whats_playing.dart';

class PlaylistStyle extends StatefulWidget {
  final String trackId;
  const PlaylistStyle({super.key, required this.trackId});

  @override
  State<PlaylistStyle> createState() => _PlaylistStyleState();
}

class _PlaylistStyleState extends State<PlaylistStyle> {
  final player = AudioPlayer();

  Set<String> songList = {};
  List<String> imageList = [];
  List<Duration> durationList = [];
  List<UrlSource> songURL = [];
  List<String> description = [];

  String? artistName;
  String? artistImage;

  int? currentSong;

  bool loading = false;
  bool otherMusic = false;

  Future<void> playBottom([bool? newMusic]) async {
    if (currentSong != null) {
      if (newMusic == true) {
        player.stop();
        setState(() {
          loading = true;
          otherMusic = true;
        });
        await player.play(songURL[currentSong!]);
        setState(() {
          loading = false;
          otherMusic = false;
        });
      } else if (songURL.elementAtOrNull(currentSong!) != null) {
        if (player.state == PlayerState.stopped ||
            player.state == PlayerState.paused) {
          setState(() => loading = true);
          await player.play(songURL[currentSong!]);
          setState(() => loading = false);
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
      artistName = value.name!;
      artistImage = value.images!.first.url!;

      value.tracks?.itemsNative?.forEach((value) {
        songList.add(value['track']['name']);
        imageList.add(value['track']['album']['images'][0]['url']);
        description.add(value['track']['artists'][0]['name']);
      });

      setState(() {});
    }).then((value) async {
      final yt = YoutubeExplode();
      for (int index = 0; index != songList.length; index++) {
        final video = (await yt.search
                .search("${songList.elementAt(index)} ${artistName ?? ""}"))
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
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          artistName ?? '',
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
              itemCount: songList.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int index) {
                return songList.isNotEmpty
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
                              child: Image.network(imageList[index])),
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
                                    songList.elementAt(index),
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
                                    description.elementAt(index),
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
                              if (currentSong != index &&
                                  player.state == PlayerState.playing) {
                                currentSong = index;
                                await playBottom(true);
                              } else {
                                if (currentSong != index) {
                                  setState(() => otherMusic = true);
                                }
                                currentSong = index;
                                await playBottom();
                                setState(() => otherMusic = false);
                              }
                              setState(() {});
                            },
                            child: Stack(
                              children: [
                                if (loading == false || currentSong != index)
                                  Icon(
                                    (player.state == PlayerState.playing &&
                                            currentSong == index)
                                        ? Icons.pause_circle
                                        : Icons.play_circle,
                                    color: songURL.elementAtOrNull(index) !=
                                            null
                                        ? Colors.green
                                        : const Color.fromARGB(255, 75, 97, 75),
                                    size: (width + height) * 0.04,
                                  ),
                                if (loading == true && currentSong == index)
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
                  nameMusic: songList.elementAt(currentSong!),
                  imageMusic: imageList[currentSong!],
                  descriptionMusic: description.elementAt(currentSong!),
                  playBottom: playBottom,
                  player: player,
                  otherMusic: otherMusic,
                  duration: durationList[currentSong!],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
