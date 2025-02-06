import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/music_player.dart';
import 'package:spotify/spotify.dart' as sptf;

import '../Utils/constants.dart';
import '../Utils/image_loader.dart';
import '../Utils/load_screen.dart';

// Classe para tocar as músicas da Lista.
class PlayMusic extends StatefulWidget {
  // ID do spotify.
  final String trackId;
  // Básico da classe.
  const PlayMusic({super.key, required this.trackId});
  // Inicia a classe Stateful.
  @override
  State<PlayMusic> createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic> {
  // Fonte de dados das músicas.
  final musicPlayer = MusicPlayer();

  // allLoad para página e Loading para o player.
  bool allLoad = false;
  bool loading = false;

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
      // Atualiza a tela e mostra o que foi carregado.
    }).then((value) => setState(() => allLoad = true));
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
          title: Row(
            children: [
              // Se tudo estiver carregado.
              if (allLoad)
                // Imagem da Playlist com tamanho personalizado e circular.
                SizedBox(
                  width: width * 0.14,
                  height: height * 0.14,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: ImageLoader().imageNetwork(
                        urlImage: musicPlayer.artistImage.elementAt(0),
                        size: width * 0.14),
                  ),
                ),
              // Adiciona um vão entre os Widget's.
              SizedBox(width: width * 0.01),
              // Nome da Playlist.
              Expanded(
                child: Text(
                  musicPlayer.playlistName.elementAtOrNull(0) ?? '',
                  style:
                      TextStyle(color: Colors.white, fontSize: width * 0.065),
                ),
              ),
            ],
          ),
        ),
        body: allLoad
            ? SingleChildScrollView(
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
                                    .elementAtOrNull(musicPlayer.songIndex) ??
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
                            TextButton(
                              onPressed: () async {
                                if (musicPlayer.songIndex != 0) {
                                  setState(() => loading = true);
                                  await musicPlayer.passMusic('Left');
                                  setState(() {
                                    musicPlayer.player.seek(Duration.zero);
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
                            Stack(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    setState(() => loading = true);

                                    try {
                                      await musicPlayer.changeMusic();

                                      if (musicPlayer.musicaCompletada()) {
                                        musicPlayer.player.seek(Duration.zero);
                                      }
                                      setState(() =>
                                          musicPlayer.musica = Duration.zero);

                                      await musicPlayer.play().then((value) {
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
                                    size: (size.width + size.height) * 0.08,
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
                                      width: (size.width + size.height) * 0.065,
                                      height:
                                          (size.width + size.height) * 0.065,
                                      child: const CircularProgressIndicator(
                                        color: Constants.color,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            TextButton(
                              onPressed: () async {
                                if (musicPlayer.songIndex !=
                                    musicPlayer.songList.length - 1) {
                                  setState(() => loading = true);
                                  await musicPlayer.passMusic('Right');
                                  setState(() {
                                    musicPlayer.player.seek(Duration.zero);
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
                                setState(() =>
                                    musicPlayer.shuffle = !musicPlayer.shuffle);
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
              )
            // Tela de Carregamento.
            : LoadScreen().loadingNormal(size));
  }
}
