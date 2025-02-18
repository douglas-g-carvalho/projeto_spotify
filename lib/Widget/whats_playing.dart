import 'package:flutter/material.dart';

import '../Utils/constants.dart';
import '../Utils/music_player.dart';
import '../Utils/image_loader.dart';

// Classe para mostrar a música quando playlist_style estiver tocando.
class WhatsPlaying extends StatefulWidget {
  // Nome da música.
  final String nameMusic;
  // Capa da música.
  final String imageMusic;
  // Nome do artista.
  final List<String> artistName;
  // MusicPlayer para saber das mesmas informações que o playlist_style.
  final MusicPlayer musicPlayer;
  // Cores para o Gradiente.
  final List<Color>? colorBackground;
  // Para saber quando mudar o ícone do botão Play para carregamento.
  final bool loading;
  // Necessário para o ProgressBar.
  final Function(bool) loadingMaster;
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
    required this.musicPlayer,
    required this.loading,
    required this.loadingMaster,
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
                    // Verifica em qual modo se encontra.
                    switch (widget.musicPlayer.repeatType) {
                      // Caso esteja em desativado.
                      case 0:
                        // Ativa o autoPlay.
                        widget.musicPlayer.autoPlay = true;
                        // Aumenta o número do repeatType.
                        widget.musicPlayer.repeatType += 1;
                      case 1:
                        // Ativa o Repetir.
                        widget.musicPlayer.repeat = true;
                        // Desativa o autoPlay.
                        widget.musicPlayer.autoPlay = false;
                        // Aumenta o número do repeatType.
                        widget.musicPlayer.repeatType += 1;
                      case 2:
                        // Desativa o Repetir.
                        widget.musicPlayer.repeat = false;
                        // Reseta o número do repeatType.
                        widget.musicPlayer.repeatType = 0;
                    }
        
                    // Atualiza a tela.
                    setState(() {});
                  },
                  child: Icon(
                    widget.musicPlayer.repeatType == 0
                        ? Icons.repeat
                        : widget.musicPlayer.repeatType == 1
                            ? Icons.repeat
                            : Icons.repeat_one,
                    size: width * 0.078,
                    color: widget.musicPlayer.repeatType == 0
                        ? Colors.white
                        : widget.musicPlayer.repeatType == 1
                            ? Constants.color
                            : Constants.color,
                  ),
                ),
                // Botão de Shuffle (Aleatório).
                TextButton(
                  onPressed: () {
                    widget.musicPlayer.shuffle = !widget.musicPlayer.shuffle;
                    setState(() {});
                  },
                  child: Icon(
                    Icons.shuffle,
                    size: width * 0.078,
                    color: widget.musicPlayer.shuffle
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
                          widget.musicPlayer.textArtists(widget.artistName),
                          style: TextStyle(
                              color: Colors.white, fontSize: width * 0.045),
                        ),
                      ),
                      // Barra de progresso da música.
                      widget.musicPlayer
                          .progressBar(size.width * 0.55, widget.loadingMaster),
                    ],
                  ),
                  // Dar um espaço entre os Widget's.
                  SizedBox(width: width * 0.03),
                  Stack(
                    children: [
                      // Ícone de Play e Carregamento.
                      widget.loading
                          ? SizedBox(
                              width: ((width + height) * 0.047),
                              height: ((width + height) * 0.047),
                              child: const CircularProgressIndicator(
                                  color: Constants.color))
                          : Icon(
                              (widget.musicPlayer.player.playing)
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
                              // Caso a música esteja completa.
                              if (widget.musicPlayer.musicaCompletada()) {
                                // Manda o player para o ínicio.
                                widget.musicPlayer.player.seek(Duration.zero);
                                // Manda a música para o ínicio.
                                setState(() =>
                                    widget.musicPlayer.musica = Duration.zero);
                              }
                              // Explicação no ínicio da classe.
                              widget.loadingMaster(true);
        
                              // Dar play na música.
                              widget.musicPlayer.play().then((value) {
                                // Explicação no ínicio da classe.
                                widget.loadingMaster(false);
                              });
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
