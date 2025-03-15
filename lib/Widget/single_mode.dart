import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:projeto_spotify/Utils/groups.dart';

import '../Utils/efficiency_utils.dart';

class SingleMode extends StatelessWidget {
  final double width;
  final double height;
  final Groups group;
  final Future<void> Function([int? index]) play;

  const SingleMode({
    super.key,
    required this.width,
    required this.height,
    required this.group,
    required this.play,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Stack(children: [
        // Imagem cobrindo o background.
        Image.network(
          width: width,
          height: height * 0.91,
          fit: BoxFit.cover,
          group.audioHandler.imageList
                  .elementAtOrNull(group.audioHandler.lastIndex ?? 0) ??
              '',
        ),
        // Caixa de Cor do tamanho da tela.
        ColoredBox(
          color: Colors.black.withOpacity(0.6),
          child: SizedBox(
            width: width,
            height: height*0.95,
          ),
        ),
        // Adiciona o Blur para tudo menos o child.
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16,
            sigmaY: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dá um espaço entre o topo da página e o s abaixo.
              SizedBox(height: height * 0.07),
              // Imagem da capa da música com tamanho personalizado e circular..
              SizedBox(
                width: width * 1,
                height: height * 0.35,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: ImageLoader().imageNetwork(
                      urlImage: group.audioHandler.imageList.elementAtOrNull(
                              group.audioHandler.lastIndex ?? 0) ??
                          '',
                      size: width * 0.80),
                ),
              ),
              // Adiciona um vão entre os s.
              SizedBox(height: height * 0.05),
              // Nome da música.
              Text(
                group.audioHandler.songList
                        .elementAtOrNull(group.audioHandler.lastIndex ?? 0) ??
                    '',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.07,
                ),
              ),
              // Barra de progresso da música.
              SizedBox(
                width: width * 0.80,
                child: group.audioHandler.customizeStreamBuilder(),
              ),
              Column(
                children: [
                  // Row para passar a música ou toca-lá.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Passar música para Esquerda.
                      TextButton(
                        onPressed: () async {
                          if (!group.audioHandler.stateLoading) {
                            if (group.audioHandler.lastIndex != 0) {
                              await group.audioHandler.skipToPrevious();
                            }
                          }
                        },
                        child: Icon(
                          (group.audioHandler.lastIndex ??
                                      group.audioHandler.listMusic.length) !=
                                  0
                              ? Icons.arrow_circle_left_outlined
                              : Icons.arrow_circle_left,
                          size: width * 0.14,
                          color: (group.audioHandler.lastIndex ??
                                      group.audioHandler.listMusic.length) !=
                                  0
                              ? (group.audioHandler.stateLoading)
                                  ? Colors.white54
                                  : Colors.white
                              : Colors.red,
                        ),
                      ),
                      // Play / Pause.
                      Stack(
                        children: [
                          TextButton(
                            onPressed: () async {
                              if (!group.audioHandler.stateLoading &&
                                  !group.audioHandler.indexBlocked.contains(
                                      group.audioHandler.multiIndex)) {
                                // Explicação se encontra na função.
                                await play();
                              }
                            },
                            child: Icon(
                              group.audioHandler.playing
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              size: (width + height) * 0.08,
                              color: (!group.audioHandler.indexBlocked
                                      .contains(group.audioHandler.multiIndex))
                                  ? (group.audioHandler.stateLoading)
                                      ? Colors.transparent
                                      : Colors.white
                                  : Colors.red,
                            ),
                          ),
                          if (group.audioHandler.stateLoading)
                            Positioned(
                              right: width * 0.05,
                              bottom: height * 0.021,
                              child: SizedBox(
                                width: (width + height) * 0.065,
                                height: (width + height) * 0.065,
                                child: const CircularProgressIndicator(
                                  color: Constants.color,
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Passar música para Direita.
                      TextButton(
                        onPressed: () async {
                          if (!group.audioHandler.stateLoading) {
                            if (group.audioHandler.lastIndex !=
                                group.audioHandler.songList.length - 1) {
                              await group.audioHandler.skipToNext();
                            }
                          }
                        },
                        child: Icon(
                          group.audioHandler.lastIndex !=
                                  group.audioHandler.songList.length - 1
                              ? Icons.arrow_circle_right_outlined
                              : Icons.arrow_circle_right,
                          size: width * 0.14,
                          color: group.audioHandler.lastIndex !=
                                  group.audioHandler.songList.length - 1
                              ? (group.audioHandler.stateLoading)
                                  ? Colors.white54
                                  : Colors.white
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  // Row para ativar ou desativar os modos (repetir, tocar próxima e aleatório).
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Modo repetir ou tocar próxima.
                      TextButton(
                        onPressed: () async {
                          // Trocar os modos entre (desativado, tocar próxima ou repetir).
                          await group.audioHandler.trueRepeatMode();
                        },
                        child: Icon(
                          group.audioHandler.repeat == 0
                              ? Icons.repeat
                              : group.audioHandler.repeat == 1
                                  ? Icons.repeat
                                  : Icons.repeat_one,
                          size: width * 0.11,
                          color: group.audioHandler.repeat == 0
                              ? Colors.white
                              : group.audioHandler.repeat == 1
                                  ? Constants.color
                                  : Constants.color,
                        ),
                      ),
                      // Modo Aleatório.
                      TextButton(
                        onPressed: () async {
                          // Ativar / Desativar o modo Aleatório.
                          await group.audioHandler.trueShuffleMode();
                        },
                        child: Icon(
                          Icons.shuffle,
                          size: width * 0.11,
                          color: group.audioHandler.shuffle
                              ? Constants.color
                              : Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
