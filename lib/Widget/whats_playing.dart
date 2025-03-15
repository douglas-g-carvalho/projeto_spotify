import 'package:flutter/material.dart';

import 'package:projeto_spotify/Utils/groups.dart';

import '../Utils/efficiency_utils.dart';

// Classe para mostrar a música quando playlist_style estiver tocando.
class WhatsPlaying extends StatelessWidget {
  // Player principal.
  final Groups group;
  // Para fechar o What's Playing caso o usuário queira.
  final Function stopWidget;

  // Básico da classe.
  const WhatsPlaying({
    super.key,
    required this.group,
    required this.stopWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Pega o tamanho da tela e armazena.
    final Size size = MediaQuery.sizeOf(context);
    // Salva o width.
    final double width = size.width;
    // Salva o height.
    final double height = size.height;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Colors.purple, Colors.cyan]),
        border: Border.all(
          color: Constants.color,
          width: width * 0.005,
        ),
      ),
      height: height * 0.21,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Deletar, Repetir / AutoPlay, Shuffle (Aleatório).
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botão de deletar.
                TextButton(
                  onPressed: () {
                    // Explicação da Função no começo da classe.
                    stopWidget();
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: width * 0.078,
                  ),
                ),
                // Botão de (Desativado / AutoPlay / Repetir).
                TextButton(
                  onPressed: () {
                    // Trocar os modos entre (desativado, tocar próxima ou repetir).
                    group.audioHandler.trueRepeatMode();
                  },
                  child: Icon(
                    group.audioHandler.repeat == 0
                        ? Icons.repeat
                        : group.audioHandler.repeat == 1
                            ? Icons.repeat
                            : Icons.repeat_one,
                    size: width * 0.10,
                    color: group.audioHandler.repeat == 0
                        ? Colors.white
                        : group.audioHandler.repeat == 1
                            ? Constants.color
                            : Constants.color,
                  ),
                ),
                // Botão de Shuffle (Aleatório).
                TextButton(
                  onPressed: () {
                    group.audioHandler.trueShuffleMode();
                  },
                  child: Icon(
                    Icons.shuffle,
                    size: width * 0.10,
                    color: group.audioHandler.shuffle
                        ? Constants.color
                        : Colors.white,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Capa da música.
                  ImageLoader().imageNetwork(
                      urlImage: group.audioHandler
                          .imageList[group.audioHandler.lastIndex!],
                      size: width * 0.25),
                  // Dar um espaço entre Widget's.
                  SizedBox(width: width * 0.03),
                  // Nome da música e artistas.
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nome da música.
                      SizedBox(
                        width: width * 0.44,
                        child: Text(
                          group.audioHandler.songList
                              .elementAt(group.audioHandler.lastIndex!),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: height * 0.023,
                          ),
                        ),
                      ),
                      // Nome dos artistas.
                      SizedBox(
                        width: width * 0.44,
                        child: Text(
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          group.audioHandler
                              .artistName[group.audioHandler.lastIndex!],
                          style: TextStyle(
                              color: Colors.white, fontSize: width * 0.045),
                        ),
                      ),
                      // Barra de progresso da música.
                      SizedBox(
                          width: size.width * 0.50,
                          child: group.audioHandler.customizeStreamBuilder()),
                    ],
                  ),
                  // Dar um espaço entre os Widget's.
                  SizedBox(width: width * 0.03),
                  Stack(
                    children: [
                      // Ícone de Play e Carregamento.
                      (group.audioHandler.stateLoading)
                          ? SizedBox(
                              width: ((width + height) * 0.047),
                              height: ((width + height) * 0.047),
                              child: const CircularProgressIndicator(
                                  color: Constants.color))
                          : Icon(
                              group.audioHandler.playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Constants.color,
                              size: width * 0.144,
                            ),
                      // Botão para dar Play com hitbox do tamanho do ícone de Play.
                      TextButton(
                          style: ElevatedButton.styleFrom(
                            splashFactory: group.audioHandler.stateLoading
                                ? NoSplash.splashFactory
                                : InkSplash.splashFactory,
                            minimumSize: Size(0.1, 0.1),
                          ),
                          onPressed: () {
                            // Caso carregar seja false.
                            if (!group.audioHandler.stateLoading) {
                              // Dar play na música.
                              if (!group.audioHandler.playing) {
                                group.audioHandler.play();
                              } else {
                                group.audioHandler.pause();
                              }
                            }
                          },
                          child: SizedBox(
                            width: width * 0.09,
                            height: height * 0.055,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
