import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/groups.dart';

import 'package:projeto_spotify/Widget/search_play.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Utils/efficiency_utils.dart';

// Classe criada para pesquisar no Youtube.
class Search extends StatefulWidget {
  final Groups group;
  const Search({required this.group, super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  // Map que salva as informações dos vídeos.
  Map<int, Map<String, Object>> mapSearch = {};

  // Controle de Texto para o TextFormField.
  late TextEditingController controller;

  int indexSearch = 0;

  bool loading = false;
  bool searchAlready = false;
  bool searchState = false;

  // Customiza os Views que nem tem no Youtube.
  String customizedViewCount(int views) {
    String divider = '1';
    int maxZeros;
    String viewName;

    switch (views.toString().length) {
      case > 9 && <= 12:
        maxZeros = 9;
        viewName = ' bi visualizações';
      case > 6 && <= 9:
        maxZeros = 6;
        viewName = ' mi visualizações';
      case > 3 && <= 6:
        maxZeros = 3;
        viewName = ' mil visualizações';
      case _:
        maxZeros = 0;
        viewName = ' visualizações';
    }

    for (int index = 0; index < maxZeros; index++) {
      divider += '0';
    }

    double viewsCountFinal = (views / int.parse(divider));
    int stringFixed = 1;

    if ([' mil visualizações', ' mi visualizações', ' bi visualizações']
            .contains(viewName) &&
        viewsCountFinal >= 10) {
      stringFixed = 0;
    }

    return (viewsCountFinal.toStringAsFixed(stringFixed)).replaceAll('.0', '') +
        viewName;
  }

  // Customiza a Duração que nem tem no Youtube.
  String customizedDuration(Duration duration) {
    int second = duration.inSeconds - 1;
    int minute = 0;
    int hour = 0;

    while (second >= 60) {
      minute += 1;
      second -= 60;
    }

    while (minute >= 60) {
      hour += 1;
      minute -= 60;
    }

    String secondsString = second != 0
        ? second < 10
            ? '0${second.round()}'
            : '${second.round()}'
        : '00';

    String minutesString = minute != 0
        ? minute < 10
            ? '0${minute.round()}:'
            : '${minute.round()}:'
        : '00:';

    String hourString = hour != 0 ? '${hour.round()}:' : '';

    return hourString + minutesString + secondsString;
  }

  // Muda a data do uploadDate para o padrão do Brasil.
  String customizedUploadDate(DateTime? uploadDate) {
    if (uploadDate == null) {
      return '- Sem data';
    }
    return '- ${uploadDate.day}/${uploadDate.month}/${uploadDate.year}';
  }

  // Traduz os dados do uploadDateRaw recebidos do Youtube.
  String customizedDataAgo(String? uploadDateRaw) {
    if (uploadDateRaw == null) {
      return '';
    }

    Map<String, String> correction = {
      'years': 'anos',
      'year': 'ano',
      'months': 'meses',
      'month': 'mes',
      'week': 'semana',
      'weeks': 'semanas',
      'days': 'dias',
      'day': 'dia',
      'hours': 'horas',
      'hour': 'hora',
      'ago': '',
    };

    String newText = 'há ';

    for (String letters in uploadDateRaw.split(' ')) {
      if (correction.containsKey(letters)) {
        letters = correction[letters]!;
      }
      newText += '$letters ';
    }
    if (newText.contains('Streamed')) {
      newText = 'Transmitido ${newText.replaceAll('Streamed ', '')}';
    }
    return newText;
  }

  // Procura os videos com base no que foi pesquisado.
  Future<void> searchVideos(VideoSearchList video) async {
    for (int index = 0; index < video.length; index++) {
      try {
        mapSearch.addAll({
          index: {
            'ID': video[index].id,
            'Title': video[index].title,
            'Author': video[index].author,
            'Views': customizedViewCount(video[index].engagement.viewCount),
            'UploadDate': video[index].uploadDate ?? 'Sem data',
            'UploadDateString': customizedUploadDate(video[index].uploadDate),
            'UploadDateRaw': customizedDataAgo(video[index].uploadDateRaw),
            'Duration': customizedDuration(video[index].duration!),
          }
        });
      } catch (error) {
        continue;
      }
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    // Atribuindo o Editor de Texto.
    controller = TextEditingController();
    super.initState();
  }

  // Função do Flutter para quando a Página fechar.
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pega o tamanho da tela e armazena.
    final size = MediaQuery.of(context).size;
    // Salva o width.
    final width = size.width;
    // Salva o height.
    final height = size.height;
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
      bottomNavigationBar: searchState
          ? null
          : BottomNavigationBar(
              backgroundColor: Colors.black,
              selectedIconTheme: const IconThemeData(color: Constants.color),
              unselectedIconTheme: const IconThemeData(color: Colors.white),
              selectedItemColor: Constants.color,
              unselectedItemColor: Colors.white,
              currentIndex: 1,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: 'Inicio'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search), label: 'Buscar'),
              ],
              onTap: (value) {
                switch (value) {
                  case 0:
                    Navigator.pushNamed(context, '/inicio');
                  case 1:
                    Navigator.pushNamed(context, '/buscar');
                }
              },
            ),
      body: SafeArea(
        child: searchState
            // SearchPlay.
            ? StreamBuilder(
                stream: widget.group.audioHandler.playbackState.stream,
                builder: (context, snapshot) {
                  return SearchPlay(
                    leading: TextButton(
                      onPressed: () {
                        if (searchState) {
                          widget.group.audioHandler.dispose();
                          searchState = false;
                          setState(() {});
                        }
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: searchState ? Colors.white : Colors.transparent,
                      ),
                    ),
                    id: mapSearch[indexSearch]!['ID'] as VideoId,
                    title: mapSearch[indexSearch]!['Title'] as String,
                    author: mapSearch[indexSearch]!['Author'] as String,
                    viewCount: mapSearch[indexSearch]!['Views'] as String,
                    uploadDate:
                        mapSearch[indexSearch]!['UploadDateString'] as String,
                    uploadDateRaw:
                        mapSearch[indexSearch]!['UploadDateRaw'] as String,
                    duration: mapSearch[indexSearch]!['Duration'] as String,
                    group: widget.group,
                  );
                },
              )
            :
            // Pesquisa.
            SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: width * 0.02),
                          // Ícone de pesquisa.
                          Icon(
                            Icons.search,
                            color: Colors.white,
                            size: height * 0.04,
                          ),
                          // TextField.
                          SizedBox(
                            width: width * 0.80,
                            child: TextField(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: height * 0.024,
                              ),
                              cursorColor: Colors.white,
                              keyboardType: TextInputType.text,
                              controller: controller,
                              onSubmitted: (String value) async {
                                if (value != '') {
                                  // Apaga o mapSearch caso outra pesquisa seja feita.
                                  if (mapSearch.isNotEmpty) {
                                    setState(() => mapSearch = {});
                                  }

                                  setState(() => loading = true);

                                  // Pesquisa no Youtube o que foi digitado.
                                  final video = (await YoutubeExplode()
                                      .search
                                      .search(value,
                                          filter: TypeFilters.video));

                                  try {
                                    // Explicação se encontra na Função.
                                    searchVideos(video);
                                  } catch (error) {
                                    // Reseta o mapSearch.
                                    setState(() {
                                      mapSearch = {};
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.01),
                      if (loading)
                        // Tela de Carregamento.
                        SizedBox(
                          height: height * 0.84,
                          child: LoadScreen().loadingNormal(size),
                        )
                      else
                        // Multi com informações do mapSearch.
                        mapSearch.isNotEmpty
                            ? SizedBox(
                                width: width,
                                height: height * 0.84,
                                child: ListView.separated(
                                    itemCount: mapSearch.length - 1,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: height * 0.01),
                                    itemBuilder: (context, index) {
                                      return Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white)),
                                        child: TextButton(
                                          style: ElevatedButton.styleFrom(
                                              shape:
                                                  const RoundedRectangleBorder()),
                                          onPressed: () {
                                            // Vai para search_play.
                                            indexSearch = index;
                                            searchState = !searchState;
                                            WakelockPlus.enable();

                                            setState(() {});
                                          },
                                          child: Row(
                                            children: [
                                              // Ícone de nota músical.
                                              Icon(
                                                Icons.music_note,
                                                color: Colors.white,
                                                size: width * 0.1,
                                              ),
                                              Column(
                                                children: [
                                                  // Título do video.
                                                  SizedBox(
                                                    width: width * 0.80,
                                                    child: Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      mapSearch[index]!['Title']
                                                          as String,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  // Dar um espaço entre os Widget's.
                                                  SizedBox(
                                                      height: height * 0.01),
                                                  // Autor e Data.
                                                  Row(
                                                    children: [
                                                      Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        mapSearch[index]![
                                                            'Author'] as String,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      SizedBox(
                                                          width: width * 0.015),
                                                      Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        '${mapSearch[index]!['UploadDateString']}',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                  // Dar um espaço entre os Widget's.
                                                  SizedBox(
                                                      height: height * 0.01),
                                                  // Ícone de olho, Contagem das views e a Duração.
                                                  Row(
                                                    children: [
                                                      // Ícone de olho.
                                                      Icon(
                                                        Icons.remove_red_eye,
                                                        color: Colors.white,
                                                        size: width * 0.05,
                                                      ),
                                                      // Dar um espaço entre os Widget's.
                                                      SizedBox(
                                                          width: width * 0.01),
                                                      // Contagem de views.
                                                      Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        mapSearch[index]![
                                                            'Views'] as String,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      // Dar um espaço entre os Widget's.
                                                      SizedBox(
                                                          width: width * 0.01),
                                                      // Duração.
                                                      Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        '- Duração: ${mapSearch[index]!['Duration']}',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : SizedBox(
                                height: height * 0.84,
                              ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
