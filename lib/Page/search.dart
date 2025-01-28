import 'package:flutter/material.dart';

import 'package:projeto_spotify/Widget/search_play.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Utils/constants.dart';
import '../Utils/load_screen.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Map<int, Map<String, Object>> mapSearch = {};

  late TextEditingController controller;

  bool loading = false;
  bool searchAlready = false;

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

  String customizedUploadDate(DateTime? uploadDate) {
    if (uploadDate == null) {
      return '- Sem data';
    }
    return '- ${uploadDate.day}/${uploadDate.month}/${uploadDate.year}';
  }

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
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedIconTheme: const IconThemeData(color: Constants.color),
        unselectedIconTheme: const IconThemeData(color: Colors.white),
        selectedItemColor: Constants.color,
        unselectedItemColor: Colors.white,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search,
                        color: Colors.white, size: height * 0.05),
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
                            if (mapSearch.isNotEmpty) {
                              setState(() => mapSearch = {});
                            }

                            setState(() => loading = true);

                            final video = (await YoutubeExplode()
                                .search
                                .search(value, filter: TypeFilters.video));

                            try {
                              searchVideos(video);
                            } catch (error) {
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
                if (mapSearch.isNotEmpty)
                  SingleChildScrollView(
                    child: SizedBox(
                      width: width,
                      height: height * 0.83,
                      child: ListView.separated(
                        itemCount: mapSearch.length - 1,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: height * 0.01),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white)),
                            child: TextButton(
                              style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder()),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SearchPlay(
                                      id: mapSearch[index]!['ID'] as VideoId,
                                      title:
                                          mapSearch[index]!['Title'] as String,
                                      author:
                                          mapSearch[index]!['Author'] as String,
                                      viewCount:
                                          mapSearch[index]!['Views'] as String,
                                      uploadDate:
                                          mapSearch[index]!['UploadDateString']
                                              as String,
                                      uploadDateRaw:
                                          mapSearch[index]!['UploadDateRaw']
                                              as String,
                                      duration: mapSearch[index]!['Duration']
                                          as String,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: width * 0.1,
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: width * 0.80,
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          mapSearch[index]!['Title'] as String,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(height: height * 0.01),
                                      Row(
                                        children: [
                                          Text(
                                            textAlign: TextAlign.center,
                                            mapSearch[index]!['Author']
                                                as String,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          SizedBox(width: width * 0.015),
                                          Text(
                                            textAlign: TextAlign.center,
                                            '${mapSearch[index]!['UploadDateString']}',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: height * 0.01),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.remove_red_eye,
                                            color: Colors.white,
                                            size: width * 0.05,
                                          ),
                                          SizedBox(width: width * 0.01),
                                          Text(
                                            textAlign: TextAlign.center,
                                            mapSearch[index]!['Views']
                                                as String,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          SizedBox(width: width * 0.01),
                                          Text(
                                            textAlign: TextAlign.center,
                                            '- Duração: ${mapSearch[index]!['Duration']}',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (loading) LoadScreen().loadingNormal(size)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
