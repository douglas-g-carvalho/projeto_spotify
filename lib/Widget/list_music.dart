import 'package:flutter/material.dart';

import '../Utils/groups.dart';
import 'music_choices.dart';

class ListMusic extends StatefulWidget {
  final Groups group;
  final Set<Map<String, String>> mapListMusics;

  const ListMusic({
    required this.group,
    required this.mapListMusics,
    super.key,
  });

  @override
  State<ListMusic> createState() => _ListMusicState();
}

class _ListMusicState extends State<ListMusic> {
  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: false,
  );

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double width = size.width;
    final double height = size.height;

    return SizedBox(
      height: height * 0.32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // vai da metade pra baixo
          SizedBox(
            width: width * 0.475,
            height: height * 0.40,
            child: ListView.separated(
              controller: scrollController,
              itemCount: (widget.mapListMusics.length / 2).round(),
              separatorBuilder: (_, int index) {
                return const SizedBox(height: 5);
              },
              itemBuilder: (_, int index) {
                return MusicChoices(
                  texto: widget.mapListMusics.elementAtOrNull(index)?['name']!,
                  icon: widget.mapListMusics.elementAtOrNull(index)?['cover']!,
                  spotify: widget.mapListMusics.elementAtOrNull(index)?['spotify']!,
                );
              },
            ),
          ),
          // vão entre eles
          SizedBox(
            width: width * 0.05,
            height: height * 0.40,
          ),
          // vai da metade pra cima
          SizedBox(
            width: width * 0.475,
            height: height * 0.40,
            child: ListView.separated(
              controller: scrollController,
              itemCount: (widget.mapListMusics.length / 2).floor(),
              separatorBuilder: (_, int index) {
                return const SizedBox(height: 5);
              },
              itemBuilder: (_, int index) {
                return MusicChoices(
                  texto: widget.mapListMusics.elementAt(index +
                      (widget.mapListMusics.length / 2).round())['name']!,
                  icon: widget.mapListMusics.elementAt(index +
                      (widget.mapListMusics.length / 2).round())['cover']!,
                  spotify: widget.mapListMusics.elementAt(index +
                      (widget.mapListMusics.length / 2).round())['spotify']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
