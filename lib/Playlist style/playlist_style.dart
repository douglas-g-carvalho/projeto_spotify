import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as spot;

import '../Geral/Constants/constants.dart';

class PlaylistStyle extends StatefulWidget {
  final String trackId;
  const PlaylistStyle({super.key, required this.trackId});

  @override
  State<PlaylistStyle> createState() => _PlaylistStyleState();
}

class _PlaylistStyleState extends State<PlaylistStyle> {
  Set<String> songList = {};
  List<String> imageList = [];
  String? artistName;
  String? artistImage;
  List<String> description = [];

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
    });

    // spotify.tracks.get(music.trackId).then((track) async {
    //   String? tempSongName = track.name;
    //   if (tempSongName != null) {
    //     music.songName = tempSongName;
    //     music.artistName = track.artists?.first.name ?? "";
    //     String? image = track.album?.images?.first.url;
    //     if (image != null) {
    //       music.songImage = image;
    //     }
    //   }
    //   music.artistImage = track.artists?.first.images?.first.url;
    //   setState(() {});
    //   final yt = YoutubeExplode();
    //   final video =
    //       (await yt.search.search("$tempSongName ${music.artistName ?? ""}"))
    //           .first;

    //   final videoId = video.id.value;
    //   music.duration = video.duration;

    //   var manifest = await yt.videos.streamsClient.getManifest(videoId);
    //   var audioUrl = manifest.audioOnly.last.url;
    //   player.play(UrlSource(audioUrl.toString()));
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(width: 5),
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
                          width: 80,
                          height: 80,
                          child: Image.network(imageList[index])),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          SizedBox(
                            width: 280,
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
                            width: 280,
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
                        onPressed: () {},
                        child: const Icon(
                          Icons.play_circle,
                          color: Colors.green,
                          size: 40,
                        ),
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
