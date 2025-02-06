import 'package:flutter/material.dart';

import '../Utils/groups.dart';
import 'music_choices.dart';

// Classe criada para o usuário selecionar alguma música para escutar da Lista.
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
  // Manter a ListView sempre no topo ao iniciar o ListMusic.
  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: false,
  );

  @override
  Widget build(BuildContext context) {
    // Pega o tamanho da tela e armazena.
    final Size size = MediaQuery.sizeOf(context);
    // Salva o width.
    final double width = size.width;
    // Salva o height.
    final double height = size.height;

    return SizedBox(
      height: height * 0.32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ListView que vai da metade pra baixo.
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
                  spotify:
                      widget.mapListMusics.elementAtOrNull(index)?['spotify']!,
                );
              },
            ),
          ),
          // Adiciona um vão entre os ListView's.
          SizedBox(width: width * 0.05, height: height * 0.40),
          // ListView que vai da metade pra cima
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
