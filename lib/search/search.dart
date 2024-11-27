import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // int indexVideos = 0;
    //   final yt = YoutubeExplode();
    //   for (int index = 0; index != newPlayInfo.songList!.length; index++) {
    //     final video = (await yt.search.search(
    //             "${newPlayInfo.songList!.elementAt(index)} ${newPlayInfo.artistName ?? ""} music"))[
    //         indexVideos];

    //     if (video.duration! > const Duration(minutes: 20)) {
    //       indexVideos++;
    //       index--;
    //       continue;
    //     } else {
    //       indexVideos = 0;
    //     }

    //     final videoId = video.id.value;
    //     newPlayInfo.durationList!.add(video.duration!);

    //     var manifest = await yt.videos.streamsClient.getManifest(videoId);
    //     var audioUrl = manifest.audioOnly.last.url;

    //     newPlayInfo.songURL!.add(UrlSource(audioUrl.toString()));
    //     setState(() {});
    //   }

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
