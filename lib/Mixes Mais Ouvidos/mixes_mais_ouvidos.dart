import 'package:flutter/material.dart';
import 'package:projeto_spotify/Playlist%20style/playlist_style.dart';

import '../Geral/Constants/constants.dart';
import 'Componentes/mixes.dart';
import 'package:spotify/spotify.dart';

class MixesMaisOuvidos extends StatefulWidget {
  const MixesMaisOuvidos({super.key});

  @override
  State<MixesMaisOuvidos> createState() => _MixesMaisOuvidosState();
}

class _MixesMaisOuvidosState extends State<MixesMaisOuvidos> {
  final List<String> listGroups = [
    '37i9dQZF1E4yDLLdhzbPqY',
    '37i9dQZF1E4wKXrAP0YkOe',
    '37i9dQZF1E4kS7EClyxsob',
    '37i9dQZF1E4ttzrPMX55m8',
  ];

  List<String> artistImage = [];
  List<String> description = [];
  List<String> listID = [];

  @override
  void initState() {
    for (int index = 0; index != listGroups.length; index++) {
      final credentials =
          SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
      final spotify = SpotifyApi(credentials);

      spotify.playlists.get(listGroups[index]).then((value) {
        artistImage.add(value.images!.first.url!);
        description.add(value.description!);
        listID.add(value.id!);

        setState(() {});
      });
    }

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
    return Column(
      children: [
        Text(
          artistImage.length == listGroups.length
              ? 'Seus mixes mais ouvidos'
              : '',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
          width: double.infinity,
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: listGroups.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 5),
            itemBuilder: (BuildContext context, int index) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: artistImage.length == listGroups.length
                    ? Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            width: 170,
                            height: 170,
                            child: Mixes().mixes(
                              teste: artistImage[index],
                              extra: true,
                            ),
                          ),
                          Positioned(
                            top: 170,
                            left: 10,
                            child: SizedBox(
                              width: 150,
                              child: Text(
                                textAlign: TextAlign.center,
                                description[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => PlaylistStyle(
                                          trackId: listID[index])));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const SizedBox(
                              height: 170,
                              width: 146,
                            ),
                          ),
                        ],
                      )
                    : const Placeholder(color: Colors.transparent),
              );
            },
          ),
        ),
      ],
    );
  }
}
