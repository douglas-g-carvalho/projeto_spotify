import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

import '../Geral/Constants/constants.dart';
import 'Componentes/music_choices.dart';

class EightyMusic extends StatefulWidget {
  const EightyMusic({super.key});

  @override
  State<EightyMusic> createState() => _EightyMusicState();
}

class _EightyMusicState extends State<EightyMusic> {
  final List<String> listGroups = [
    '6AsR0V6KWciPEVnZfIFKnX',
    '2AltltuDppkFyGloecxjzs',
    '6bpPKPIWEPnvLmqRc7GLzw',
    '08eJerYHHTin58iXQjQHpK',
    '5tEzEAdmKqsugZxOq9YajR',
    '60egqvG5M5ilZM8Js4hCkG',
    '7234K2ZNVmAfetWuSguT7V',
    '0Mgok0vqQjNAsLV5WyJvAq',
  ];

  final Map<int, Map<String, String>> mapMusics = {};

  ScrollController scrollController = ScrollController(
    initialScrollOffset: 100,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    for (int index = 0; index != listGroups.length; index++) {
      final credentials =
          SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
      final spotify = SpotifyApi(credentials);

      spotify.playlists.get(listGroups[index]).then((value) {
        mapMusics.addAll({
          index: {'name': value.name!}
        });
        mapMusics[index]!.addAll({'cover': value.images!.first.url!});
        mapMusics[index]!.addAll({'spotify': value.id!});

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
    final Size size = MediaQuery.sizeOf(context);
    final double width = size.width;
    final double height = size.height;

    return SizedBox(
      height: height*0.33,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // vai do mapMusics de 0 a 3;
          if (mapMusics.length == listGroups.length)
            SizedBox(
              width: width * 0.475,
              height: height * 0.40,
              child: ListView.separated(
                controller: scrollController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, int index) {
                  return const SizedBox(height: 5);
                },
                itemBuilder: (_, int index) {
                  return MusicChoices(
                    texto: mapMusics[index]!['name']!,
                    icon: mapMusics[index]!['cover']!,
                    spotify: mapMusics[index]!['spotify']!,
                  );
                },
              ),
            ),
          SizedBox(
            width: width * 0.05,
            height: height*0.40,
          ),
          // vai do mapMusics de 4 a 7;
          if (mapMusics.length == listGroups.length)
            SizedBox(
              width: width * 0.475,
              height: height * 0.40,
              child: ListView.separated(
                controller: scrollController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, int index) {
                  return const SizedBox(height: 5);
                },
                itemBuilder: (_, int index) {
                  return MusicChoices(
                    texto: mapMusics[index + 4]!['name']!,
                    icon: mapMusics[index + 4]!['cover']!,
                    spotify: mapMusics[index + 4]!['spotify']!,
                  );
                },
              ),
            ),
          if (mapMusics.length != listGroups.length)
            const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }
}
