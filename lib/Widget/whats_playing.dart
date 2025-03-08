import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/audio_player_handler.dart';
import 'package:projeto_spotify/Utils/groups.dart';

import '../Utils/constants.dart';
import '../Utils/image_loader.dart';

// Classe para mostrar a música quando playlist_style estiver tocando.
class WhatsPlaying extends StatefulWidget {
  // Nome da música.
  final String nameMusic;
  // Capa da música.
  final String imageMusic;
  // Nome do artista.
  final String artistName;
  // MusicPlayer para saber das mesmas informações que o playlist_style.
  // final MusicPlayer musicPlayer;
  final AudioPlayerHandler audioHandler;
  // Player principal.
  final Groups group;
  // Cores para o Gradiente.
  final List<Color>? colorBackground;
  // Para saber quando mudar o ícone do botão Play para carregamento.
  final bool loading;
  // Duração da música.
  final Duration duration;
  // Para fechar o What's Playing caso o usuário queira.
  final Function stopWidget;

  // Básico da classe.
  const WhatsPlaying({
    super.key,
    required this.nameMusic,
    required this.imageMusic,
    required this.artistName,
    required this.colorBackground,
    required this.audioHandler,
    required this.group,
    required this.loading,
    required this.duration,
    required this.stopWidget,
  });

  @override
  State<WhatsPlaying> createState() => _WhatsPlayingState();
}

class _WhatsPlayingState extends State<WhatsPlaying> {
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
          colors: widget.colorBackground ??
              [
                Colors.purple.shade900,
                Colors.green.shade900,
              ],
        ),
        border: Border.all(
          color: Constants.color,
          width: width * 0.005,
        ),
      ),
      height: height * 0.21,
      width: width * 0.995,
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
                    widget.stopWidget();
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
                    widget.group.audioHandler.trueRepeatMode();
                    // Atualizar a tela.
                    setState(() {});
                  },
                  child: Icon(
                    widget.group.audioHandler.repeat == 0
                        ? Icons.repeat
                        : widget.group.audioHandler.repeat == 1
                            ? Icons.repeat
                            : Icons.repeat_one,
                    size: width * 0.10,
                    color: widget.group.audioHandler.repeat == 0
                        ? Colors.white
                        : widget.group.audioHandler.repeat == 1
                            ? Constants.color
                            : Constants.color,
                  ),
                ),
                // // Botão de Shuffle (Aleatório).
                TextButton(
                  onPressed: () {
                    widget.audioHandler.trueShuffleMode();
                    setState(() {});
                  },
                  child: Icon(
                    Icons.shuffle,
                    size: width * 0.10,
                    color: widget.audioHandler.shuffle
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
                      urlImage: widget.imageMusic, size: width * 0.25),
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
                          widget.nameMusic,
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
                          widget.artistName,
                          style: TextStyle(
                              color: Colors.white, fontSize: width * 0.045),
                        ),
                      ),
                      // Barra de progresso da música.
                      SizedBox(
                          width: size.width * 0.50,
                          child: widget.group.audioHandler
                              .customizeStreamBuilder()),
                    ],
                  ),
                  // Dar um espaço entre os Widget's.
                  SizedBox(width: width * 0.03),
                  Stack(
                    children: [
                      // Ícone de Play e Carregamento.
                      (widget.loading ||
                              widget.group.audioHandler.stateLoading ==
                                  'loading')
                          ? SizedBox(
                              width: ((width + height) * 0.047),
                              height: ((width + height) * 0.047),
                              child: const CircularProgressIndicator(
                                  color: Constants.color))
                          : Icon(
                              widget.group.audioHandler.playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Constants.color,
                              size: width * 0.144,
                            ),
                      // Botão para dar Play com hitbox do tamanho do ícone de Play.
                      TextButton(
                          style: ElevatedButton.styleFrom(
                            splashFactory: widget.loading
                                ? NoSplash.splashFactory
                                : InkSplash.splashFactory,
                            minimumSize: Size(0.1, 0.1),
                          ),
                          onPressed: () {
                            // Caso carregar seja false.
                            if (!widget.loading) {
                              // Dar play na música.
                              if (!widget.audioHandler.playing) {
                                widget.audioHandler.play();
                              } else {
                                widget.audioHandler.pause();
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
