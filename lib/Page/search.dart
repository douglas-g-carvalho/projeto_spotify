import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:projeto_spotify/Models/search_model.dart';
import 'package:projeto_spotify/Widget/search_play.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  SearchModel searchModel = SearchModel(
    id: [],
    title: [],
    author: [],
    viewCount: [],
    uploadDate: [],
    uploadDateRaw: [],
    duration: [],
    urlSound: [],
  );

  late TextEditingController controller;
  String textSearch = '';
  bool loading = false;

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
    int second = duration.inSeconds;
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

  String customizedDataAgo(String uploadDateRaw) {
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
        selectedIconTheme: const IconThemeData(color: Colors.green),
        unselectedIconTheme: const IconThemeData(color: Colors.white),
        selectedItemColor: Colors.green,
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
              Navigator.pushNamed(context, '/');
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
                            if (searchModel.id!.isNotEmpty) {
                              searchModel.id = [];
                              searchModel.title = [];
                              searchModel.author = [];
                              searchModel.viewCount = [];
                              searchModel.uploadDate = [];
                              searchModel.uploadDateRaw = [];
                              searchModel.duration = [];
                              searchModel.urlSound = [];
                            }
                            setState(() => loading = true);
                            final yt = YoutubeExplode();

                            final video = (await yt.search
                                .search(value, filter: TypeFilters.video));

                            for (int index = 0; index < video.length; index++) {
                              int maybeError = 0;
                              try {
                                maybeError += 1;
                                searchModel.id!.add(video[index].id.value);
                                maybeError += 1;
                                searchModel.title!.add(video[index].title);
                                maybeError += 1;
                                searchModel.author!.add(video[index].author);

                                maybeError += 1;
                                searchModel.viewCount!.add(customizedViewCount(
                                    video[index].engagement.viewCount));

                                maybeError += 1;
                                searchModel.uploadDate!
                                    .add(video[index].uploadDate!);

                                maybeError += 1;
                                searchModel.uploadDateRaw!.add(
                                    customizedDataAgo(
                                        video[index].uploadDateRaw!));

                                maybeError += 1;
                                searchModel.duration!.add(
                                    customizedDuration(video[index].duration!));

                                maybeError += 1;
                                var manifest = await yt.videos.streamsClient
                                    .getManifest(video[index].id.value);
                                var audioUrl = manifest.audioOnly.last.url;

                                searchModel.urlSound!
                                    .add(UrlSource(audioUrl.toString()));
                              } catch (error) {
                                for (int errors = 0;
                                    errors != maybeError - 1;
                                    errors++) {
                                  switch (errors) {
                                    case 0:
                                      searchModel.id!
                                          .remove(video[index].id.value);
                                    case 1:
                                      searchModel.title!
                                          .remove(video[index].title);
                                    case 2:
                                      searchModel.author!
                                          .remove(video[index].author);
                                    case 3:
                                      searchModel.viewCount!.remove(
                                          customizedViewCount(video[index]
                                              .engagement
                                              .viewCount));
                                    case 4:
                                      searchModel.uploadDate!
                                          .remove(video[index].uploadDate);
                                    case 5:
                                      searchModel.uploadDateRaw!.remove(
                                          customizedDataAgo(
                                              video[index].uploadDateRaw!));
                                    case 6:
                                      searchModel.duration!.remove(
                                          customizedDuration(
                                              video[index].duration!));
                                  }
                                }
                              }
                              if (searchModel.id!.isNotEmpty) {
                                setState(() => loading = false);
                                setState(() {});
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (searchModel.id!.isNotEmpty)
                  SingleChildScrollView(
                    child: SizedBox(
                      width: width,
                      height: height * 0.83,
                      child: ListView.separated(
                        itemCount: searchModel.id!.length - 1,
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
                                      title: searchModel.title![index],
                                      author: searchModel.author![index],
                                      viewCount: searchModel.viewCount![index],
                                      uploadDate:
                                          searchModel.uploadDate![index],
                                      uploadDateRaw:
                                          searchModel.uploadDateRaw![index],
                                      duration: searchModel.duration![index],
                                      urlSound: searchModel.urlSound![index],
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
                                          searchModel.title![index],
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(height: height * 0.01),
                                      Row(
                                        children: [
                                          Text(
                                            textAlign: TextAlign.center,
                                            searchModel.author![index],
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          SizedBox(width: width * 0.015),
                                          Text(
                                            textAlign: TextAlign.center,
                                            '${searchModel.uploadDate![index].day}/${searchModel.uploadDate![index].month}/${searchModel.uploadDate![index].year}',
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
                                            searchModel.viewCount![index],
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          SizedBox(width: width * 0.01),
                                          Text(
                                            textAlign: TextAlign.center,
                                            '- Duração: ${searchModel.duration![index]}',
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
                if (loading)
                  Column(
                    children: [
                      SizedBox(height: height * 0.41),
                      SizedBox(
                        width: width * 0.12,
                        height: height * 0.06,
                        child: const CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
