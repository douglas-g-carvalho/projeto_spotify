import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as sptf;
import 'package:projeto_spotify/Utils/music_player.dart';

import '../Widget/whats_playing.dart';

import '../Utils/image_loader.dart';
import '../Utils/load_screen.dart';
import '../Utils/constants.dart';

// Classe para tocar as músicas do Mixes.
class PlayStyle extends StatefulWidget {
  // ID do spotify.
  final String trackId;
  // Básico da classe.
  const PlayStyle({super.key, required this.trackId});

  @override
  State<PlayStyle> createState() => _PlayStyleState();
}

class _PlayStyleState extends State<PlayStyle> {
  // Fonte de dados das músicas.
  final musicPlayer = MusicPlayer();
  // Para mudar o estilo visual da página.
  bool changeMode = false;
  // Loading para o player.
  bool loading = false;
  // Para saber quando precisar trocar o SongIndex do MusicPlayer.
  bool otherMusic = false;
  // Para saber quando está tocando música.
  bool isPlaying = false;

  // Função para progressBar conseguir mostrar quando está carregando.
  void loadingMaster(bool value) {
    // Atualiza a tela e o loading.
    setState(() => loading = value);
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
        musicPlayer.playlistName.add(value.name!);
        // Adiciona a imagem da Playlist.
        musicPlayer.artistImage.add(value.images!.first.url!);
        // Pega faz um forEach em cada uma das músicas da Playlist.
        value.tracks?.itemsNative?.forEach((value) {
          // List com os nomes dos artistas de uma música.
          List<String> saveArtistName = [];
          // Adiciona o nome da música.
          musicPlayer.songList.add(value['track']['name']);
          // Adiciona a capa da música.
          musicPlayer.imageList
              .add(value['track']['album']['images'][0]['url']);
          // Faz um forEach para cada artista.
          value['track']['artists'].forEach((artistas) {
            // Adiciona o nome do artista.
            saveArtistName.add(artistas['name']);
          });
          // Adiciona os nomes dos artistas.
          musicPlayer.artistName
              .addAll({value['track']['name']: saveArtistName});
        });
      });
    } catch (error) {
      try {
        // Pesquisa o ID do Album e pega seus dados.
        await spotify.albums.get(widget.trackId).then((value) {
          // Adiciona o nome da Album.
          musicPlayer.playlistName.add(value.name!);
          // Adiciona a imagem da Album.
          musicPlayer.artistImage.add(value.images!.first.url!);
          // Pega faz um forEach em cada uma das músicas do Album.
          value.tracks?.forEach((value) {
            // List com os nomes dos artistas de uma música.
            List<String> saveArtistName = [];
            // Adiciona o nome da música.
            musicPlayer.songList.add(value.name!);
            // Adiciona a capa do album já que albums não tem a imagem cover para as músicas.
            musicPlayer.imageList.add(musicPlayer.artistImage.elementAt(0));
            // Faz um for in para cada artista.
            for (var artistas in value.artists!) {
              // Adiciona o nome do artista.
              saveArtistName.add(artistas.name!);
            }
            // Adiciona os nomes dos artistas.
            musicPlayer.artistName.addAll({value.name!: saveArtistName});
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
  void dispose() {
    // Limpa o player quando sair do play_music.
    musicPlayer.player.dispose();
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
            musicPlayer.playlistName.elementAtOrNull(0) ?? '',
            style: TextStyle(color: Colors.white, fontSize: width * 0.06),
          ),
          actions: [
            // Botão para trocar o estilo visual (Single Mode, ListView's Mode).
            TextButton(
              onPressed: () {
                setState(() {
                  isPlaying = false;
                  musicPlayer.player.stop();
                  changeMode = !changeMode;
                });
              },
              child: Icon(Icons.wifi_protected_setup),
            )
          ],
        ),
        body: musicPlayer.songList.isEmpty
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
                        musicPlayer.imageList
                                .elementAtOrNull(musicPlayer.songIndex) ??
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
                                    urlImage: musicPlayer.imageList
                                            .elementAtOrNull(
                                                musicPlayer.songIndex) ??
                                        '',
                                    size: width * 0.80),
                              ),
                            ),
                            // Adiciona um vão entre os Widget's.
                            SizedBox(height: size.height * 0.05),
                            // Nome da música.
                            Text(
                              musicPlayer.songList
                                      .elementAtOrNull(musicPlayer.songIndex) ??
                                  '',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.07,
                              ),
                            ),
                            // Barra de progresso da música.
                            musicPlayer.progressBar(
                              width * 0.80,
                              loadingMaster,
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
                                        if (musicPlayer.songIndex != 0) {
                                          setState(() => loading = true);
                                          await musicPlayer.passMusic('Left');
                                          setState(() {
                                            musicPlayer.player
                                                .seek(Duration.zero);
                                            loading = false;
                                          });
                                        }
                                      },
                                      child: Icon(
                                        musicPlayer.songIndex != 0
                                            ? Icons.arrow_circle_left_outlined
                                            : Icons.arrow_circle_left,
                                        size: width * 0.14,
                                        color: musicPlayer.songIndex != 0
                                            ? Colors.white
                                            : Colors.red,
                                      ),
                                    ),
                                    // Play / Pause.
                                    Stack(
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            setState(() => loading = true);

                                            try {
                                              await musicPlayer.changeMusic();

                                              if (musicPlayer
                                                  .musicaCompletada()) {
                                                musicPlayer.player
                                                    .seek(Duration.zero);
                                              }
                                              setState(() => musicPlayer
                                                  .musica = Duration.zero);

                                              await musicPlayer
                                                  .play()
                                                  .then((value) {
                                                setState(() => loading = false);
                                              });
                                            } catch (error) {
                                              setState(() => loading = false);
                                            }
                                          },
                                          child: Icon(
                                            musicPlayer.player.playing
                                                ? Icons.pause_circle
                                                : Icons.play_circle,
                                            size: (size.width + size.height) *
                                                0.08,
                                            color: loading
                                                ? Colors.transparent
                                                : Colors.white,
                                          ),
                                        ),
                                        if (loading)
                                          Positioned(
                                            right: size.width * 0.05,
                                            bottom: size.height * 0.021,
                                            child: SizedBox(
                                              width:
                                                  (size.width + size.height) *
                                                      0.065,
                                              height:
                                                  (size.width + size.height) *
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
                                        if (musicPlayer.songIndex !=
                                            musicPlayer.songList.length - 1) {
                                          setState(() => loading = true);
                                          await musicPlayer.passMusic('Right');
                                          setState(() {
                                            musicPlayer.player
                                                .seek(Duration.zero);
                                            loading = false;
                                          });
                                        }
                                      },
                                      child: Icon(
                                        musicPlayer.songIndex !=
                                                musicPlayer.songList.length - 1
                                            ? Icons.arrow_circle_right_outlined
                                            : Icons.arrow_circle_right,
                                        size: width * 0.14,
                                        color: musicPlayer.songIndex !=
                                                musicPlayer.songList.length - 1
                                            ? Colors.white
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
                                      onPressed: () {
                                        // Trocar os modos entre (desativado, tocar próxima ou repetir).
                                        switch (musicPlayer.repeatType) {
                                          case 0:
                                            musicPlayer.autoPlay = true;
                                            musicPlayer.repeatType += 1;
                                          case 1:
                                            musicPlayer.repeat = true;
                                            musicPlayer.autoPlay = false;
                                            musicPlayer.repeatType += 1;
                                          case 2:
                                            musicPlayer.repeat = false;
                                            musicPlayer.repeatType = 0;
                                        }
                                        // Atualizar a tela.
                                        setState(() {});
                                      },
                                      child: Icon(
                                        musicPlayer.repeatType == 0
                                            ? Icons.repeat
                                            : musicPlayer.repeatType == 1
                                                ? Icons.repeat
                                                : Icons.repeat_one,
                                        size: width * 0.11,
                                        color: musicPlayer.repeatType == 0
                                            ? Colors.white
                                            : musicPlayer.repeatType == 1
                                                ? Constants.color
                                                : Constants.color,
                                      ),
                                    ),
                                    // Modo Aleatório.
                                    TextButton(
                                      onPressed: () {
                                        setState(() => musicPlayer.shuffle =
                                            !musicPlayer.shuffle);
                                      },
                                      child: Icon(
                                        Icons.shuffle,
                                        size: width * 0.11,
                                        color: musicPlayer.shuffle
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
                      // Widger principal do Stack.
                      const SizedBox(height: double.infinity),
                      // ListView com as músicas do Mixes.
                      Container(
                        padding: const EdgeInsets.all(5),
                        width: double.infinity,
                        height: isPlaying ? height * 0.705 : double.infinity,
                        child: ListView.separated(
                          itemCount: musicPlayer.songList.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              SizedBox(height: height * 0.01),
                          itemBuilder: (BuildContext context, int index) {
                            return musicPlayer.songList.isNotEmpty
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
                                            urlImage: musicPlayer.imageList
                                                    .elementAtOrNull(index) ??
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
                                              musicPlayer.songList
                                                  .elementAt(index),
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
                                              musicPlayer.textArtists(
                                                  musicPlayer.artistName[
                                                      musicPlayer.songList
                                                          .elementAt(index)]!),
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
                                          if (loading == true) {
                                            return;
                                          }

                                          setState(() => loading = true);

                                          if (musicPlayer.songIndex != index) {
                                            musicPlayer.player.pause();
                                          }

                                          musicPlayer.songIndex = index;

                                          await musicPlayer.changeMusic();

                                          musicPlayer.play();
                                          isPlaying = true;
                                          setState(() => loading = false);
                                        },
                                        child: Stack(
                                          children: [
                                            Icon(
                                              (musicPlayer.player.playing &&
                                                      musicPlayer.songList
                                                              .elementAt(
                                                                  index) ==
                                                          musicPlayer
                                                              .actualSong)
                                                  ? Icons.pause_circle
                                                  : Icons.play_circle,
                                              color: loading
                                                  ? Colors.transparent
                                                  : Constants.color,
                                              size: (width + height) * 0.04,
                                            ),
                                            if (loading == true &&
                                                musicPlayer.songList
                                                        .elementAt(index) ==
                                                    musicPlayer.actualSong)
                                              Positioned(
                                                top: height * 0.008,
                                                right: width * 0.015,
                                                child: SizedBox(
                                                  width:
                                                      ((width + height) * 0.03),
                                                  height:
                                                      ((width + height) * 0.03),
                                                  child:
                                                      const CircularProgressIndicator(
                                                          color:
                                                              Constants.color),
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
                      // Se estiver tocando.
                      if (isPlaying)
                        // Widget com informações como Capa, Nome, Artista, Barra de Progresso e Botão de Play.
                        Positioned(
                          bottom: 0,
                          child: WhatsPlaying(
                            nameMusic: musicPlayer.songList
                                .elementAt(musicPlayer.songIndex),
                            imageMusic:
                                musicPlayer.imageList[musicPlayer.songIndex],
                            artistName: musicPlayer.artistName[musicPlayer
                                .songList
                                .elementAt(musicPlayer.songIndex)]!,
                            musicPlayer: musicPlayer,
                            colorBackground: [Colors.purple, Colors.cyan],
                            loading: loading,
                            loadingMaster: loadingMaster,
                            duration: musicPlayer.mapDuration[musicPlayer
                                    .songList
                                    .elementAt(musicPlayer.songIndex)] ??
                                Duration.zero,
                            stopWidget: () {
                              setState(() {
                                isPlaying = false;
                                musicPlayer.player.stop();
                              });
                            },
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
