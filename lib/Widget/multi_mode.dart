import 'package:flutter/material.dart';

import '../Utils/efficiency_utils.dart';
import '../Utils/groups.dart';

import 'whats_playing.dart';

class MultiMode extends StatelessWidget {
  final double width;
  final double height;
  final Groups group;
  final bool isPlaying;
  final Future<void> Function([int? index]) play;
  final Function stopWidget;

  const MultiMode({
    super.key,
    required this.width,
    required this.height,
    required this.group,
    required this.isPlaying,
    required this.play,
    required this.stopWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Widget principal do Stack.
        const SizedBox(height: double.infinity),
        // ListView com as músicas do Mixes.
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            height: height * (isPlaying ? 0.70 : 0.915),
            child: ListView.separated(
              itemCount: group.audioHandler.songList.length,
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: height * 0.01),
              itemBuilder: (BuildContext context, int index) {
                return group.audioHandler.songList.isNotEmpty
                    ? Row(
                        children: [
                          // Número da Música.
                          Material(
                            color: Colors.transparent,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: width * 0.05),
                            ),
                          ),
                          // Dar um espaço entre os Widget's.
                          SizedBox(width: width * 0.02),
                          // Capa da música.
                          SizedBox(
                            width: width * 0.20,
                            height: height * 0.10,
                            child: ImageLoader().imageNetwork(
                                urlImage: group.audioHandler.imageList
                                        .elementAtOrNull(index) ??
                                    '',
                                size: width * 0.21),
                          ),
                          // Dar um espaço entre os Widget's.
                          SizedBox(width: width * 0.02),
                          // Nome e Artistas da música.
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Nome da música.
                              SizedBox(
                                width: index < 9
                                    ? width * 0.50
                                    : index < 99
                                        ? width * 0.47
                                        : width * 0.45,
                                child: Text(
                                  group.audioHandler.songList
                                          .elementAtOrNull(index) ??
                                      '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: height * 0.025,
                                  ),
                                ),
                              ),
                              // Nome dos artistas.
                              SizedBox(
                                width: index < 9
                                    ? width * 0.50
                                    : index < 99
                                        ? width * 0.47
                                        : width * 0.45,
                                child: Text(
                                  group.audioHandler.artistName
                                          .elementAtOrNull(index) ??
                                      '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: height * 0.025,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Botão de Play.
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                            ),
                            onPressed: () async {
                              if (!group.audioHandler.stateLoading &&
                                  !group.audioHandler.indexBlocked
                                      .contains(index)) {
                                // Explicação se encontra na função.
                                await play(index);
                              }
                            },
                            child: Stack(
                              children: [
                                Icon(
                                  (group.audioHandler.playing &&
                                          group.audioHandler.multiIndex ==
                                              index)
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  color: (!group.audioHandler.indexBlocked
                                          .contains(index))
                                      ? (group.audioHandler.stateLoading)
                                          ? Colors.transparent
                                          : Constants.color
                                      : Colors.red,
                                  size: (width + height) * 0.04,
                                ),
                                if ((group.audioHandler.stateLoading) &&
                                    group.audioHandler.multiIndex == index)
                                  Positioned(
                                    top: height * 0.008,
                                    right: width * 0.015,
                                    child: SizedBox(
                                      width: ((width + height) * 0.03),
                                      height: ((width + height) * 0.03),
                                      child: const CircularProgressIndicator(
                                          color: Constants.color),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    // Placeholder para quando não tiver carregado as músicas.
                    : const Placeholder(color: Colors.transparent);
              },
            ),
          ),
        ),
        // Se estiver tocando.
        if (isPlaying)
          // Widget com informações como Capa, Nome, Artista, Barra de Progresso e Botão de Play.
          Positioned(
            bottom: height * 0.005,
            child: WhatsPlaying(group: group, stopWidget: stopWidget),
          ),
      ],
    );
  }
}
