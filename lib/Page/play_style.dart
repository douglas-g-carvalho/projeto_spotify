import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/groups.dart';
import 'package:spotify/spotify.dart' as sptf;

import '../Utils/efficiency_utils.dart';
import '../Widget/multi_mode.dart';
import '../Widget/single_mode.dart';

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
  // Para saber quando está tocando música.
  bool isPlaying = false;

  // Play customizado para Single Mode ou Multi Mode.
  Future<void> play([int? index]) async {
    if (!changeMode) {
      // Multi Mode.

      if (widget.group.audioHandler.lastIndex != index) {
        if (widget.group.audioHandler.playing) {
          widget.group.audioHandler.pause();
        }

        if (!widget.group.audioHandler.listMusic.containsKey(index)) {
          await widget.group.audioHandler.loadMusic(index!);
        } else {
          await widget.group.audioHandler.setAudioSolo(
            widget.group.audioHandler.playlist,
            index!,
          );
        }
      }

      if (!widget.group.audioHandler.playing) {
        widget.group.audioHandler.play();
      } else {
        widget.group.audioHandler.pause();
      }
    } else {
      // Single Mode.

      if (!widget.group.audioHandler.playing) {
        widget.group.audioHandler.play();
      } else {
        widget.group.audioHandler.pause();
      }
    }

    if (isPlaying == false) {
      setState(() => isPlaying = true);
    }
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
    // Salva o tamanho do StatusBar.
    final appBarSize = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: appBarSize,
        backgroundColor: Colors.black,
        leading: TextButton(
          onPressed: null,
          child: Icon(
            Icons.ac_unit_outlined,
            color: Colors.transparent,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [Colors.blue, Colors.yellow])),
        child: StreamBuilder(
          stream: widget.group.audioHandler.playbackState.stream,
          builder: (context, snapshot) {
            return Scaffold(
              backgroundColor: Colors.black.withOpacity(0.75),
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                centerTitle: true,
                title: Text(
                  widget.group.audioHandler.playlistName.elementAtOrNull(0) ??
                      '',
                  style: TextStyle(color: Colors.white, fontSize: width * 0.06),
                ),
                actions: [
                  // Botão para trocar o estilo visual (Single Mode, Multi Mode).
                  TextButton(
                    onPressed: () async {
                      if (!widget.group.audioHandler.stateLoading) {
                        setState(() => changeMode = !changeMode);

                        if (widget.group.audioHandler.currentIndex == null) {
                          await widget.group.audioHandler.loadMusic(0);
                          await widget.group.audioHandler.pause();
                          await widget.group.audioHandler.seek(Duration.zero);
                          isPlaying = true;
                        } else if (widget.group.audioHandler.playing) {
                          await widget.group.audioHandler.pause();
                        }
                      }
                    },
                    child: Icon(
                      Icons.wifi_protected_setup,
                      color: (widget.group.audioHandler.stateLoading)
                          ? Colors.purple[1000]
                          : Colors.purple,
                    ),
                  )
                ],
              ),
              body: widget.group.audioHandler.songList.isEmpty
                  ? LoadScreen().loadingNormal(size)
                  : SafeArea(
                      child: changeMode
                          // Single Mode.
                          ? SingleMode(
                              width: width,
                              height: height,
                              group: widget.group,
                              play: play,
                            )
                          // Multi Mode.
                          : MultiMode(
                              width: width,
                              height: height,
                              group: widget.group,
                              isPlaying: isPlaying,
                              play: play,
                              stopWidget: () {
                                setState(() {
                                  isPlaying = false;
                                  widget.group.audioHandler.stop();
                                });
                              },
                            ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
