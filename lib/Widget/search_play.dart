import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:projeto_spotify/Utils/music_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Utils/constants.dart';

// Classe para dar play nos vídeos da Página Search.
class SearchPlay extends StatefulWidget {
  // Informações necessárias para mostrar ao usuário e funcionamento da classe.
  final VideoId id;
  final String title;
  final String author;
  final String viewCount;
  final String uploadDate;
  final String uploadDateRaw;
  final String duration;
  // Básico da classe.
  const SearchPlay({
    super.key,
    required this.id,
    required this.title,
    required this.author,
    required this.viewCount,
    required this.uploadDate,
    required this.uploadDateRaw,
    required this.duration,
  });

  @override
  State<SearchPlay> createState() => _SearchPlayState();
}

class _SearchPlayState extends State<SearchPlay> {
  // Fonte de dados das músicas.
  MusicPlayer musicPlayer = MusicPlayer();
  // Loading para o player.
  bool loading = false;
  // inicia nulo e apenas depois da Função audioIsOn se torna o áudio do vídeo.
  dynamic audioUrl;

  // Função para progressBar conseguir mostrar quando está carregando.
  loadingMaster(bool value) {
    // Atualiza a tela e o loading.
    setState(() => loading = value);
  }

  // Função para converter a duração do vídeo no formato Duration.
  Duration stringToDuration(String durationString) {
    // Exemplo de como a durationString chega na função.
    // 8 caracteres -> 10:30:25 -> 10 hora, 30 minutos e 25 segundos.
    // os ":" também conta na contagem de caracteres.
    // Pega o número de caracteres da durationString.
    switch (durationString.length) {
      // Exemplo de case == 8: 10:30:25 -> 10 hora, 30 minutos e 25 segundos.
      case == 8:
        return Duration(
          hours: int.parse('${durationString[0]}${durationString[1]}'),
          minutes: int.parse('${durationString[3]}${durationString[4]}'),
          seconds: int.parse('${durationString[6]}${durationString[7]}'),
        );
      // Exemplo de case == 7: 1:30:25 -> 1 hora, 30 minutos e 25 segundos.
      case == 7:
        return Duration(
          hours: int.parse(durationString[0]),
          minutes: int.parse('${durationString[2]}${durationString[3]}'),
          seconds: int.parse('${durationString[5]}${durationString[6]}'),
        );
      // Exemplo de case == 5: 30:25 -> 30 minutos e 25 segundos.
      case == 5:
        return Duration(
            minutes: int.parse('${durationString[0]}${durationString[1]}'),
            seconds: int.parse('${durationString[3]}${durationString[4]}'));
      // Exemplo de case == 4: 3:25 -> 3 minutos e 25 segundos.
      case == 4:
        return Duration(
            seconds: int.parse('${durationString[2]}${durationString[3]}'));
      case _:
        return const Duration(seconds: 0);
    }
  }

  // Função para carregar o áudio.
  Future<void> audioIsOn() async {
    // Se o áudio estiver nulo.
    if (audioUrl == null) {
      // Pesquisa pelo ID do vídeo.
      var manifest =
          await YoutubeExplode().videos.streamsClient.getManifest(widget.id);
      // Pega a URL do vídeo.
      audioUrl = manifest.audioOnly.last.url;
      // Carrega o áudio da URL no player.
      await musicPlayer.player.setAudioSource(AudioSource.uri(audioUrl));
    }
  }

  // Quando for sair do search_play.
  @override
  void dispose() {
    // Limpa o player quando sair do search_play.
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

    // Se o mapDuration está vazio.
    if (musicPlayer.mapDuration.isEmpty) {
      // Adiciona o título.
      musicPlayer.songList.addAll({widget.title});
      // Adiciona a duração.
      musicPlayer.mapDuration
          .addAll({widget.title: stringToDuration(widget.duration)});
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          textAlign: TextAlign.center,
          widget.author,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          children: [
            // Adiciona um espaço caso não tenha data do vídeo.
            if (widget.uploadDate == '- Sem data')
              SizedBox(height: height * 0.001),
            // Ícone music_video já que não tem capa.
            Icon(
              Icons.music_video,
              size: width * 0.75,
              color: Colors.white,
            ),
            // Título.
            SizedBox(
              width: width * 0.90,
              child: Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.065,
                ),
              ),
            ),
            // Dar um espaço entre os Widget's.
            SizedBox(height: height * 0.01),
            // Contagem de views.
            Text(
              textAlign: TextAlign.center,
              widget.viewCount,
              style: TextStyle(color: Constants.color, fontSize: width * 0.06),
            ),
            // Dar um espaço entre os Widget's.
            SizedBox(height: height * 0.01),
            // Caso tenha data do vídeo.
            if (widget.uploadDate != '- Sem data')
              //  Data do vídeo e Data de quanto tempo o vídeo foi enviado.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Data de quanto tempo o vídeo foi enviado.
                  Text(
                    textAlign: TextAlign.center,
                    widget.uploadDateRaw,
                    style: TextStyle(
                        color: Constants.color, fontSize: width * 0.06),
                  ),
                  //  Data do vídeo.
                  Text(
                    textAlign: TextAlign.center,
                    widget.uploadDate,
                    style: TextStyle(
                        color: Constants.color, fontSize: width * 0.06),
                  ),
                ],
              ),
            // Dar um espaço entre os Widget's.
            SizedBox(height: height * 0.01),
            // Barra de progresso da música.
            musicPlayer.progressBar(width * 0.80, loadingMaster),
            // Modo shuffle desativado (para deixar tudo centralizado), botão de Play e modo repetir.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shuffle (para deixar centralizado).
                TextButton(
                  onPressed: () {},
                  style:
                      const ButtonStyle(splashFactory: NoSplash.splashFactory),
                  child: Icon(
                    Icons.shuffle,
                    size: width * 0.12,
                    color: Colors.grey,
                  ),
                ),
                // Botão de Play.
                TextButton(
                  onPressed: () async {
                    // atualiza a tela e o bool loading.
                    setState(() => loading = true);
                    // Faz uma checagem para caso o áudio não tenha sido carregado.
                    await audioIsOn();

                    // Se a música estiver completa.
                    if (musicPlayer.musicaCompletada()) {
                      // Vai para o ínicio da barra de progresso.
                      musicPlayer.player.seek(Duration.zero);
                      // Atualiza a tela e a música para o ínicio.
                      setState(() => musicPlayer.musica = Duration.zero);
                    }

                    // Se o player estiver pausado ou parado.
                    if (!musicPlayer.player.playing) {
                      // Começa a tocar a música.
                      musicPlayer.player.play();
                    } else {
                      // Pausa a música.
                      await musicPlayer.player.pause();
                    }
                    // Atualiza a tela e o bool loading.
                    setState(() => loading = false);
                  },
                  child: Stack(
                    children: [
                      Icon(
                        musicPlayer.player.playing
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        size: width * 0.38,
                        color: loading ? Colors.transparent : Constants.color,
                      ),
                      if (loading)
                        Positioned(
                          top: width * 0.04,
                          right: width * 0.04,
                          child: SizedBox(
                            width: width * 0.30,
                            height: height * 0.14,
                            child: const CircularProgressIndicator(
                              color: Constants.color,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                // Repetir.
                TextButton(
                  onPressed: () {
                    // Troca o bool do repetir.
                    musicPlayer.repeat = !musicPlayer.repeat;
                    // Atualiza a tela.
                    setState(() {});
                  },
                  child: Icon(
                    musicPlayer.repeat ? Icons.repeat_one : Icons.repeat,
                    size: width * 0.12,
                    color: musicPlayer.repeat ? Constants.color : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
