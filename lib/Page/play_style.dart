import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/groups.dart';
import 'package:spotify/spotify.dart' as sptf;
// import 'package:projeto_spotify/Utils/music_player.dart';

import '../Widget/whats_playing.dart';

import '../Utils/image_loader.dart';
import '../Utils/load_screen.dart';
import '../Utils/constants.dart';

// Classe para tocar as músicas do Mixes.
class PlayStyle extends StatefulWidget {
  // ID do spotify.
  final String trackId;

  final Groups group;

  // Básico da classe.
  const PlayStyle({required this.trackId, required this.group, super.key});

  @override
  State<PlayStyle> createState() => _PlayStyleState();
}

class _PlayStyleState extends State<PlayStyle> {
  // Para mudar o estilo visual da página.
  bool changeMode = false;
  // Loading para o player.
  bool loading = false;
  // IndexFake para mostrar que está carregando.
  int indexFake = 0;
  // Para saber quando está tocando música.
  bool isPlaying = false;

  // Play customizado para Single Mode ou ListView's Mode.
  Future<void> play([index]) async {
    if (!changeMode) {
      // ListView's Mode.

      setState(() => loading = true);

      if (widget.group.audioHandler.lastIndex != index) {
        if (widget.group.audioHandler.playing) {
          widget.group.audioHandler.pause();
        }
        await widget.group.audioHandler.loadMusic(index);
      }

      if (!widget.group.audioHandler.playing) {
        widget.group.audioHandler.play().then((value) {
          isPlaying = true;
        });
      } else {
        widget.group.audioHandler.pause();
      }
      setState(() => loading = false);
    } else {
      setState(() => loading = true);

      if (!widget.group.audioHandler.playing) {
        widget.group.audioHandler.play();
      } else {
        widget.group.audioHandler.pause();
      }
      setState(() => loading = false);
    }
  }

  // Atualiza a tela com base na notificação.
  Future<bool?> updateScreen() async {
    if (widget.group.audioHandler.stateLoading == 'loading') {
      return true;
    } else if (widget.group.audioHandler.stateLoading == 'ready') {
      return false;
    }
    return null;
  }

  // Pega as informações da Playlist/Albums.
  Future<void> getInfo() async {
    // Ambos são necessário para conseguir usar a API do Spotify.
    final credentials =
        sptf.SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = sptf.SpotifyApi(credentials);

    try {
      // Pesquisa o ID da playlist e pega seus dados.
      await spotify.playlists.get(widget.trackId).then((value) {
        // Adiciona o nome da Playlist.
        widget.group.audioHandler.playlistName.add(value.name!);
        // Adiciona a imagem da Playlist.
        widget.group.audioHandler.artistImage.add(value.images!.first.url!);
        // Pega faz um forEach em cada uma das músicas da Playlist.
        value.tracks?.itemsNative?.forEach((value) {
          // List com os nomes dos artistas de uma música.
          List<String> saveArtistName = [];
          // Adiciona o nome da música.
          widget.group.audioHandler.songList.add(value['track']['name']);
          // Adiciona a capa da música.
          widget.group.audioHandler.imageList
              .add(value['track']['album']['images'][0]['url']);
          // Faz um forEach para cada artista.
          value['track']['artists'].forEach((artistas) {
            // Adiciona o nome do artista.
            saveArtistName.add(artistas['name']);
          });
          // Adiciona os nomes dos artistas.
          widget.group.audioHandler.artistName
              .add(widget.group.audioHandler.textArtists(saveArtistName));
        });
      });
    } catch (error) {
      try {
        // Pesquisa o ID do Album e pega seus dados.
        await spotify.albums.get(widget.trackId).then((value) {
          // Adiciona o nome da Album.
          widget.group.audioHandler.playlistName.add(value.name!);
          // Adiciona a imagem da Album.
          widget.group.audioHandler.artistImage.add(value.images!.first.url!);
          // Pega faz um forEach em cada uma das músicas do Album.
          value.tracks?.forEach((value) {
            // List com os nomes dos artistas de uma música.
            List<String> saveArtistName = [];
            // Adiciona o nome da música.
            widget.group.audioHandler.songList.add(value.name!);
            // Adiciona a capa do album já que albums não tem a imagem cover para as músicas.
            widget.group.audioHandler.imageList
                .add(widget.group.audioHandler.artistImage.elementAt(0));
            // Faz um for in para cada artista.
            for (var artistas in value.artists!) {
              // Adiciona o nome do artista.
              saveArtistName.add(artistas.name!);
            }
            // Adiciona os nomes dos artistas.
            widget.group.audioHandler.artistName
                .add(widget.group.audioHandler.textArtists(saveArtistName));
          });
        });
      } finally {}
    }
  }

  // Quando o play_music for iniciado.
  @override
  void initState() {
    // Explicação se encontra na função.
    getInfo().then((value) {
      // Atualiza a tela.
      setState(() {});
    });

    super.initState();
  }

  // Quando for sair do play_music.
  @override
  void dispose() async {
    // Limpa o player quando sair do play_music.
    widget.group.audioHandler.dispose();
    super.dispose();
  }

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
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [Colors.blue, Colors.yellow])),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.75),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            widget.group.audioHandler.playlistName.elementAtOrNull(0) ?? '',
            style: TextStyle(color: Colors.white, fontSize: width * 0.06),
          ),
          actions: [
            // Botão para trocar o estilo visual (Single Mode, ListView's Mode).
            TextButton(
              onPressed: () async {
                if (!loading) {
                  setState(() {
                    changeMode = !changeMode;
                    loading = true;
                  });

                  if (widget.group.audioHandler.currentIndex == null) {
                    await widget.group.audioHandler.loadMusic(0);
                    await widget.group.audioHandler.pause();
                    await widget.group.audioHandler.seek(Duration.zero);
                  } else if (widget.group.audioHandler.playing) {
                    await widget.group.audioHandler.pause();
                  }

                  setState(() => loading = false);
                }
              },
              child: Icon(
                Icons.wifi_protected_setup,
                color: loading ? Colors.purple[1000] : Colors.purple,
              ),
            )
          ],
        ),
        body: StreamBuilder<PlaybackState>(
          stream: widget.group.audioHandler.playbackState,
          builder: (context, snapshot) {
            if (widget.group.audioHandler.lastIndex != indexFake) {
              indexFake = widget.group.audioHandler.lastIndex ?? 0;
            }

            return widget.group.audioHandler.songList.isEmpty
                ? LoadScreen().loadingNormal(size)
                : changeMode
                    // Single Mode
                    ? SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Stack(children: [
                          // Imagem cobrindo o background.
                          Image.network(
                            width: width,
                            height: height * 0.91,
                            fit: BoxFit.cover,
                            widget.group.audioHandler.imageList.elementAtOrNull(
                                    widget.group.audioHandler.lastIndex ?? 0) ??
                                '',
                          ),
                          // Caixa de Cor do tamanho da tela.
                          ColoredBox(
                            color: Colors.black.withOpacity(0.6),
                            child: SizedBox(
                              width: width,
                              height: height,
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
                                // Dá um espaço entre o topo da página e o Widget's abaixo.
                                SizedBox(height: size.height * 0.07),
                                // Imagem da capa da música com tamanho personalizado e circular..
                                SizedBox(
                                  width: size.width * 1,
                                  height: size.height * 0.35,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: ImageLoader().imageNetwork(
                                        urlImage: widget
                                                .group.audioHandler.imageList
                                                .elementAtOrNull(widget
                                                        .group
                                                        .audioHandler
                                                        .lastIndex ??
                                                    0) ??
                                            '',
                                        size: width * 0.80),
                                  ),
                                ),
                                // Adiciona um vão entre os Widget's.
                                SizedBox(height: size.height * 0.05),
                                // Nome da música.
                                Text(
                                  widget.group.audioHandler.songList
                                          .elementAtOrNull(widget.group
                                                  .audioHandler.lastIndex ??
                                              0) ??
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
                                    width: size.width * 0.80,
                                    child: widget.group.audioHandler
                                        .customizeStreamBuilder()),
                                Column(
                                  children: [
                                    // Row para passar a música ou toca-lá.
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Passar música para Esquerda.
                                        TextButton(
                                          onPressed: () async {
                                            if (!loading) {
                                              if (widget.group.audioHandler
                                                      .lastIndex !=
                                                  0) {
                                                setState(() => loading = true);
                                                await widget.group.audioHandler
                                                    .skipToPrevious();
                                                setState(() => loading = false);
                                              }
                                            }
                                          },
                                          child: Icon(
                                            widget.group.audioHandler
                                                        .lastIndex !=
                                                    0
                                                ? Icons
                                                    .arrow_circle_left_outlined
                                                : Icons.arrow_circle_left,
                                            size: width * 0.14,
                                            color: widget.group.audioHandler
                                                        .lastIndex !=
                                                    0
                                                ? loading
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
                                                if (widget.group.audioHandler
                                                        .lastIndex ==
                                                    null) {
                                                  setState(
                                                      () => loading = true);
                                                  await widget
                                                      .group.audioHandler
                                                      .loadMusic(0);
                                                }
                                                // Explicação se encontra na função.
                                                await play();
                                              },
                                              child: Icon(
                                                widget.group.audioHandler
                                                        .playing
                                                    ? Icons.pause_circle
                                                    : Icons.play_circle,
                                                size:
                                                    (size.width + size.height) *
                                                        0.08,
                                                color: (loading ||
                                                        widget
                                                                .group
                                                                .audioHandler
                                                                .stateLoading ==
                                                            'loading')
                                                    ? Colors.transparent
                                                    : Colors.white,
                                              ),
                                            ),
                                            if (loading ||
                                                widget.group.audioHandler
                                                        .stateLoading ==
                                                    'loading')
                                              Positioned(
                                                right: size.width * 0.05,
                                                bottom: size.height * 0.021,
                                                child: SizedBox(
                                                  width: (size.width +
                                                          size.height) *
                                                      0.065,
                                                  height: (size.width +
                                                          size.height) *
                                                      0.065,
                                                  child:
                                                      const CircularProgressIndicator(
                                                    color: Constants.color,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        // Passar música para Direita.
                                        TextButton(
                                          onPressed: () async {
                                            if (!loading) {
                                              if (widget.group.audioHandler
                                                      .lastIndex !=
                                                  widget.group.audioHandler
                                                          .songList.length -
                                                      1) {
                                                setState(() => loading = true);
                                                await widget.group.audioHandler
                                                    .skipToNext();
                                                setState(() {
                                                  loading = false;
                                                });
                                              }
                                            }
                                          },
                                          child: Icon(
                                            widget.group.audioHandler
                                                        .lastIndex !=
                                                    widget.group.audioHandler
                                                            .songList.length -
                                                        1
                                                ? Icons
                                                    .arrow_circle_right_outlined
                                                : Icons.arrow_circle_right,
                                            size: width * 0.14,
                                            color: widget.group.audioHandler
                                                        .lastIndex !=
                                                    widget.group.audioHandler
                                                            .songList.length -
                                                        1
                                                ? loading
                                                    ? Colors.white54
                                                    : Colors.white
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Row para ativar ou desativar os modos (repetir, tocar próxima e aleatório).
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Modo repetir ou tocar próxima.
                                        TextButton(
                                          onPressed: () {
                                            // Trocar os modos entre (desativado, tocar próxima ou repetir).
                                            widget.group.audioHandler
                                                .trueRepeatMode();
                                            // Atualizar a tela.
                                            setState(() {});
                                          },
                                          child: Icon(
                                            widget.group.audioHandler.repeat ==
                                                    0
                                                ? Icons.repeat
                                                : widget.group.audioHandler
                                                            .repeat ==
                                                        1
                                                    ? Icons.repeat
                                                    : Icons.repeat_one,
                                            size: width * 0.11,
                                            color: widget.group.audioHandler
                                                        .repeat ==
                                                    0
                                                ? Colors.white
                                                : widget.group.audioHandler
                                                            .repeat ==
                                                        1
                                                    ? Constants.color
                                                    : Constants.color,
                                          ),
                                        ),
                                        // Modo Aleatório.
                                        TextButton(
                                          onPressed: () {
                                            widget.group.audioHandler
                                                .trueShuffleMode();
                                            setState(() {});
                                          },
                                          child: Icon(
                                            Icons.shuffle,
                                            size: width * 0.11,
                                            color: widget
                                                    .group.audioHandler.shuffle
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
                      )
                    // ListView's Mode
                    : Stack(
                        children: [
                          // Widget principal do Stack.
                          const SizedBox(height: double.infinity),
                          // ListView com as músicas do Mixes.
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: double.infinity,
                            height:
                                isPlaying ? height * 0.705 : double.infinity,
                            child: ListView.separated(
                              itemCount:
                                  widget.group.audioHandler.songList.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      SizedBox(height: height * 0.01),
                              itemBuilder: (BuildContext context, int index) {
                                return widget
                                        .group.audioHandler.songList.isNotEmpty
                                    ? Row(
                                        children: [
                                          // Número da Música.
                                          Material(
                                            color: Colors.transparent,
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: width * 0.05),
                                            ),
                                          ),
                                          // Dar um espaço entre os Widget's.
                                          SizedBox(width: width * 0.02),
                                          // Capa da música.
                                          SizedBox(
                                            width: width * 0.20,
                                            height: height * 0.10,
                                            child: ImageLoader().imageNetwork(
                                                urlImage: widget.group
                                                        .audioHandler.imageList
                                                        .elementAtOrNull(
                                                            index) ??
                                                    '',
                                                size: width * 0.21),
                                          ),
                                          // Dar um espaço entre os Widget's.
                                          SizedBox(width: width * 0.02),
                                          // Nome e Artistas da música.
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Nome da música.
                                              SizedBox(
                                                width: index < 9
                                                    ? width * 0.50
                                                    : index < 99
                                                        ? width * 0.47
                                                        : width * 0.45,
                                                child: Text(
                                                  widget.group.audioHandler
                                                          .songList
                                                          .elementAtOrNull(
                                                              index) ??
                                                      '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                  widget.group.audioHandler
                                                          .artistName
                                                          .elementAtOrNull(
                                                              index) ??
                                                      '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                              if (loading == false) {
                                                indexFake = index;
                                                // Explicação se encontra na função.
                                                await play(index);
                                              }
                                            },
                                            child: Stack(
                                              children: [
                                                Icon(
                                                  (widget.group.audioHandler
                                                              .playing &&
                                                          indexFake == index)
                                                      ? Icons.pause_circle
                                                      : Icons.play_circle,
                                                  color: (loading ||
                                                          widget
                                                                  .group
                                                                  .audioHandler
                                                                  .stateLoading ==
                                                              'loading')
                                                      ? Colors.transparent
                                                      : Constants.color,
                                                  size: (width + height) * 0.04,
                                                ),
                                                if ((loading ||
                                                        widget
                                                                .group
                                                                .audioHandler
                                                                .stateLoading ==
                                                            'loading') &&
                                                    indexFake == index)
                                                  Positioned(
                                                    top: height * 0.008,
                                                    right: width * 0.015,
                                                    child: SizedBox(
                                                      width: ((width + height) *
                                                          0.03),
                                                      height:
                                                          ((width + height) *
                                                              0.03),
                                                      child:
                                                          const CircularProgressIndicator(
                                                              color: Constants
                                                                  .color),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    // Placeholder para quando não tiver carregado as músicas.
                                    : const Placeholder(
                                        color: Colors.transparent);
                              },
                            ),
                          ),
                          // // Se estiver tocando.
                          if (isPlaying)
                            // Widget com informações como Capa, Nome, Artista, Barra de Progresso e Botão de Play.
                            Positioned(
                              bottom: 0,
                              child: WhatsPlaying(
                                nameMusic: widget.group.audioHandler.songList
                                    .elementAt(
                                        widget.group.audioHandler.lastIndex!),
                                imageMusic: widget.group.audioHandler.imageList[
                                    widget.group.audioHandler.lastIndex!],
                                artistName:
                                    widget.group.audioHandler.artistName[
                                        widget.group.audioHandler.lastIndex!],
                                audioHandler: widget.group.audioHandler,
                                group: widget.group,
                                colorBackground: [Colors.purple, Colors.cyan],
                                loading: loading,
                                duration:
                                    widget.group.audioHandler.durationMusic[
                                        widget.group.audioHandler.lastIndex!]!,
                                stopWidget: () {
                                  setState(() {
                                    isPlaying = false;
                                    widget.group.audioHandler.stop();
                                  });
                                },
                              ),
                            ),
                        ],
                      );
          },
        ),
      ),
    );
  }
}
