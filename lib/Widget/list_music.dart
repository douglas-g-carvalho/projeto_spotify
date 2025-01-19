import 'package:flutter/material.dart';

import '../Utils/groups.dart';
import 'music_choices.dart';

class ListMusic extends StatefulWidget {
  final Groups group;

  const ListMusic({required this.group, super.key});

  @override
  State<ListMusic> createState() => _ListMusicState();
}

class _ListMusicState extends State<ListMusic> {
  Map<int, Map<String, String>> mapListMusics = {};

  bool isLoading = true;

  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: false,
  );

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double width = size.width;
    final double height = size.height;

    if (widget.group.getMap('list').isNotEmpty) {
      mapListMusics = widget.group.getMap('list');
      setState(() => isLoading = false);
    }

    if (mapListMusics.isEmpty) {
      widget.group.loadMap('list').then((value) {
        mapListMusics = widget.group.getMap('list');
        if (mapListMusics.isNotEmpty) {
          setState(() => isLoading = false);
        }
      });
    }

    return SizedBox(
      height: height * 0.32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // vai da metade pra baixo
          if (!isLoading)
            SizedBox(
              width: width * 0.475,
              height: height * 0.40,
              child: ListView.separated(
                controller: scrollController,
                itemCount: (mapListMusics.length / 2).round(),
                separatorBuilder: (_, int index) {
                  return const SizedBox(height: 5);
                },
                itemBuilder: (_, int index) {
                  return MusicChoices(
                    texto: mapListMusics[index]!['name']!,
                    icon: mapListMusics[index]!['cover']!,
                    spotify: mapListMusics[index]!['spotify']!,
                  );
                },
              ),
            ),
          SizedBox(
            width: width * 0.05,
            height: height * 0.40,
          ),
          // vai da metade pra cima
          if (!isLoading)
            SizedBox(
              width: width * 0.475,
              height: height * 0.40,
              child: ListView.separated(
                controller: scrollController,
                itemCount: (mapListMusics.length / 2).floor(),
                separatorBuilder: (_, int index) {
                  return const SizedBox(height: 5);
                },
                itemBuilder: (_, int index) {
                  return MusicChoices(
                    texto: mapListMusics[
                        index + (mapListMusics.length / 2).round()]!['name']!,
                    icon: mapListMusics[
                        index + (mapListMusics.length / 2).round()]!['cover']!,
                    spotify: mapListMusics[index +
                        (mapListMusics.length / 2).round()]!['spotify']!,
                  );
                },
              ),
            ),
          if (isLoading)
            SizedBox(
                height: height * 0.33,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )),
        ],
      ),
    );
  }
}
