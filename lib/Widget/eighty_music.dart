import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

import '../Utils/constants.dart';
import '../Utils/groups.dart';
import 'music_choices.dart';

class EightyMusic extends StatefulWidget {
  final Groups group;

  const EightyMusic({required this.group, super.key});

  @override
  State<EightyMusic> createState() => _EightyMusicState();
}

class _EightyMusicState extends State<EightyMusic> {
  late List<String> list = widget.group.getListGroup();

  Map<int, Map<String, String>> mapMusics = {};

  ScrollController scrollController = ScrollController(
    initialScrollOffset: 100,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    final credentials =
        SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = SpotifyApi(credentials);
    if (widget.group.getMapMusics().isNotEmpty) {
      mapMusics = widget.group.getMapMusics();
      return;
    }

    for (int index = 0; index != list.length; index++) {
      spotify.playlists.get(list[index]).then((value) {
        try {
          widget.group.addMapMusics(index, 'name', value.name!);
          widget.group.addMapMusics(index, 'cover', value.images!.first.url!);
          widget.group.addMapMusics(index, 'spotify', value.id!);
        } catch (error) {
          widget.group.removeMapMusics(index);
          index -= 1;
        }

        mapMusics = widget.group.getMapMusics();
        setState(() {});
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double width = size.width;
    final double height = size.height;

    return SizedBox(
      height: height * 0.33,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // vai do mapMusics de 0 a 3;
          if (mapMusics.length == list.length)
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
            height: height * 0.40,
          ),
          // vai do mapMusics de 4 a 7;
          if (mapMusics.length == list.length)
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
          if (mapMusics.length != list.length)
            const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }
}
