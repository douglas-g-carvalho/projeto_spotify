import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spot;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Geral/Constants/constants.dart';

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

  Duration? musica = const Duration(seconds: 0);

  bool loading = false;

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
        child: ListView.separated(
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
                            width: width * 0.50,
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
                            width: width * 0.50,
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
                          if (songURL.elementAtOrNull(index) != null) {
                            if (player.state == PlayerState.stopped ||
                                player.state == PlayerState.paused) {
                              currentSong = index;

                              setState(() => loading = true);
                              await player.play(songURL[index]);
                              setState(() => loading = false);
                            } else {
                              await player.pause();
                            }

                            setState(() {});
                          }
                        },
                        child: Stack(children: [
                          if (loading == false || currentSong != index)
                            Icon(
                              (player.state == PlayerState.playing &&
                                      currentSong == index)
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              color: songURL.elementAtOrNull(index) != null
                                  ? Colors.green
                                  : const Color.fromARGB(255, 75, 97, 75),
                              size: 40,
                            ),
                          if (currentSong == index)
                            Icon(
                              Icons.lock,
                              color: (loading == true && currentSong == index)
                                  ? Colors.green
                                  : Colors.transparent,
                              size: 40,
                            ),
                        ]),
                      ),
                    ],
                  )
                : const Placeholder(color: Colors.transparent);
          },
        ),
      ),
    );
  }
}
