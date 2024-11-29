import 'package:flutter/material.dart';
import 'package:projeto_spotify/Models/search_model.dart';
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
  );

  late TextEditingController controller;
  String textSearch = '';
  bool loading = false;

  void customizedViewCount(int views) {
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

    searchModel.viewCount!.add(
        ((views / int.parse(divider)).toStringAsFixed(1)).replaceAll('.0', '') +
            viewName);

    // switch (video[index].engagement.viewCount.toString().length) {
    // case 11:
    //   if (video[index].engagement.viewCount.toString()[2] == '0') {
    //     searchModel.viewCount!.add(
    //         '${video[index].engagement.viewCount.toString()[0]}${video[index].engagement.viewCount.toString()[1]} bi de visualizações');
    //   } else {
    //     searchModel.viewCount!.add(
    //         '${video[index].engagement.viewCount.toString()[0]}${video[index].engagement.viewCount.toString()[1]},${video[index].engagement.viewCount.toString()[2]} bi de visualizações');
    //   }
    // case 10:
    //   if (video[index].engagement.viewCount.toString()[1] == '0') {
    //     searchModel.viewCount!.add(
    //         '${video[index].engagement.viewCount.toString()[0]} bi de visualizações');
    //   } else {
    //     searchModel.viewCount!.add(
    //         '${video[index].engagement.viewCount.toString()[0]},${video[index].engagement.viewCount.toString()[1]} bi de visualizações');
    //   }
    // case 9:
    //   searchModel.viewCount!.add(
    //       '${video[index].engagement.viewCount.toString()[0]}${video[index].engagement.viewCount.toString()[1]}${video[index].engagement.viewCount.toString()[2]} mi de visualizações');
    // case 8:
    //   searchModel.viewCount!.add(
    //       '${video[index].engagement.viewCount.toString()[0]}${video[index].engagement.viewCount.toString()[1]} mi de visualizações');
    // case 7:
    //   if (video[index].engagement.viewCount.toString()[1] == '0') {
    //     searchModel.viewCount!.add(
    //         '${video[index].engagement.viewCount.toString()[0]} mi de visualizações');
    //   } else {
    //     searchModel.viewCount!.add(
    //         '${video[index].engagement.viewCount.toString()[0]},${video[index].engagement.viewCount.toString()[1]} mi de visualizações');
    //   }
    // case 6:
    //   searchModel.viewCount!.add(
    //       '${video[index].engagement.viewCount.toString()[0]}${video[index].engagement.viewCount.toString()[1]}${video[index].engagement.viewCount.toString()[2]} mil de visualizações');
    // case 5:
    //   if (video[index].engagement.viewCount.toString()[2] == '0') {
    //     searchModel.viewCount!.add(
    //         '${video[index].engagement.viewCount.toString()[0]}${video[index].engagement.viewCount.toString()[1]} mil de visualizações');
    //   } else {
    //     searchModel.viewCount!.add(
    //         '${video[index].engagement.viewCount.toString()[0]}${video[index].engagement.viewCount.toString()[1]},${video[index].engagement.viewCount.toString()[2]} mil de visualizações');
    //   }
    // case 4:
    //   if (video[index].engagement.viewCount.toString()[1] == '0') {
    //     searchModel.viewCount!.add(
    //         '${video[index].engagement.viewCount.toString()[0]} mil de visualizações');
    //   } else {
    //     searchModel.viewCount!.add(
    //         '${video[index].engagement.viewCount.toString()[0]},${video[index].engagement.viewCount.toString()[1]} mil de visualizações');
    //   }
    // case < 4:
    //   searchModel.viewCount!.add(
    //       '${video[index].engagement.viewCount.toString()} visualizações');
    // }
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
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: 'Biblioteca'),
        ],
        onTap: (value) {
          switch (value) {
            case 0:
              Navigator.pushNamed(context, '/');
            case 1:
              Navigator.pushNamed(context, '/buscar');
            case 2:
              Navigator.pushNamed(context, '/biblioteca');
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
                        color: Colors.white, size: height * 0.04),
                    SizedBox(
                      width: width * 0.80,
                      child: TextField(
                        style: TextStyle(
                            color: Colors.white, fontSize: height * 0.024),
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.text,
                        controller: controller,
                        onSubmitted: (String value) async {
                          if (searchModel.id!.isNotEmpty) {
                            searchModel.id = [];
                            searchModel.title = [];
                            searchModel.author = [];
                            searchModel.viewCount = [];
                            searchModel.uploadDate = [];
                            searchModel.uploadDateRaw = [];
                            searchModel.duration = [];
                          }
                          setState(() => loading = true);
                          final yt = YoutubeExplode();
                          final video = (await yt.search
                              .search(value, filter: TypeFilters.video));

                          for (int index = 0; index != 20; index++) {
                            searchModel.id!.add(video[index].id.value);
                            searchModel.title!.add(video[index].title);
                            searchModel.author!.add(video[index].author);

                            customizedViewCount(
                                video[index].engagement.viewCount);

                            searchModel.uploadDate!
                                .add(video[index].uploadDate!);
                            searchModel.uploadDateRaw!
                                .add(video[index].uploadDateRaw!);
                            searchModel.duration!.add(video[index].duration!);
                          }

                          setState(() => loading = false);

                          setState(() {});

                          // final videoId = video.id.value;

                          // var manifest = await yt.videos.streamsClient.getManifest(videoId);
                          // var audioUrl = manifest.audioOnly.last.url;
                        },
                      ),
                    ),
                  ],
                ),
                if (searchModel.id!.isNotEmpty)
                  SingleChildScrollView(
                    child: SizedBox(
                      width: width * 0.80,
                      height: height * 0.90,
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Text(
                                  textAlign: TextAlign.center,
                                  searchModel.title![index],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: height * 0.02),
                                Row(
                                  children: [
                                    Text(
                                      textAlign: TextAlign.center,
                                      searchModel.author![index],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(width: width * 0.05),
                                    Text(
                                      textAlign: TextAlign.center,
                                      searchModel.viewCount![index],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
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
