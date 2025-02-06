import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as sptf;
import 'package:projeto_spotify/Utils/music_player.dart';

import 'whats_playing.dart';

import '../Utils/image_loader.dart';
import '../Utils/load_screen.dart';
import '../Utils/constants.dart';

// Classe para tocar as músicas do Mixes.
class PlaylistStyle extends StatefulWidget {
  // ID do spotify.
  final String trackId;
  // Básico da classe.
  const PlaylistStyle({super.key, required this.trackId});

  @override
  State<PlaylistStyle> createState() => _PlaylistStyleState();
}

class _PlaylistStyleState extends State<PlaylistStyle> {
  // Fonte de dados das músicas.
  final musicPlayer = MusicPlayer();

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

  // Quando o play_music for iniciado.
  @override
  void initState() {
    // Ambos são necessário para conseguir usar a API do Spotify.
    final credentials =
        sptf.SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = sptf.SpotifyApi(credentials);

    // Pesquisa o ID da playlist e pega seus dados.
    spotify.playlists.get(widget.trackId).then((value) {
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
        musicPlayer.imageList.add(value['track']['album']['images'][0]['url']);
        // Faz um forEach para cada artista.
        value['track']['artists'].forEach((artistas) {
          // Adiciona o nome do artista.
          saveArtistName.add(artistas['name']);
        });
        // Adiciona os nomes dos artistas.
        musicPlayer.artistName.addAll({value['track']['name']: saveArtistName});
      });
      // Atualiza a tela.
    }).then((value) => setState(() {}));
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

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          musicPlayer.playlistName.elementAtOrNull(0) ?? '',
          style: TextStyle(color: Colors.white, fontSize: width * 0.055),
        ),
      ),
      body: musicPlayer.songList.isEmpty
          ? LoadScreen().loadingNormal(size)
          : Stack(
              children: [
                // Widger principal do Stack.
                const SizedBox(height: double.infinity),
                // ListView com as músicas do Mixes.
                Container(
                  decoration: const BoxDecoration(color: Colors.black),
                  padding: const EdgeInsets.all(5),
                  width: double.infinity,
                  height: isPlaying ? height * 0.69 : double.infinity,
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
                                      urlImage: musicPlayer.imageList[index],
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
                                        musicPlayer.songList.elementAt(index),
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
                                            musicPlayer.artistName[musicPlayer
                                                .songList
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
                                                        .elementAt(index) ==
                                                    musicPlayer.actualSong)
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
                                            width: ((width + height) * 0.03),
                                            height: ((width + height) * 0.03),
                                            child:
                                                const CircularProgressIndicator(
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
                // Se estiver tocando.
                if (isPlaying)
                // Widget com informações como Capa, Nome, Artista, Barra de Progresso e Botão de Play.
                  Positioned(
                    bottom: 0,
                    child: WhatsPlaying(
                      nameMusic:
                          musicPlayer.songList.elementAt(musicPlayer.songIndex),
                      imageMusic: musicPlayer.imageList[musicPlayer.songIndex],
                      artistName: musicPlayer.artistName[musicPlayer.songList
                          .elementAt(musicPlayer.songIndex)]!,
                      musicPlayer: musicPlayer,
                      loading: loading,
                      loadingMaster: loadingMaster,
                      duration: musicPlayer.mapDuration[musicPlayer.songList
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
    );
  }
}
