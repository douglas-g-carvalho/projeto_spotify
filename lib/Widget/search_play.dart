import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/music_player.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:just_audio/just_audio.dart';

class SearchPlay extends StatefulWidget {
  final String title;
  final String author;
  final String viewCount;
  final DateTime uploadDate;
  final String uploadDateRaw;
  final String duration;
  final AudioSource urlSound;

  const SearchPlay({
    super.key,
    required this.title,
    required this.author,
    required this.viewCount,
    required this.uploadDate,
    required this.uploadDateRaw,
    required this.duration,
    required this.urlSound,
  });

  @override
  State<SearchPlay> createState() => _SearchPlayState();
}

class _SearchPlayState extends State<SearchPlay> {
  MusicPlayer musicPlayer = MusicPlayer();
  bool loading = false;

  loadingMaster(bool value) {
    setState(() => loading = value);
  }

  Duration stringToDuration(String durationString) {
    switch (durationString.length) {
      case == 8:
        return Duration(
          hours: int.parse('${durationString[0]}${durationString[1]}'),
          minutes: int.parse('${durationString[3]}${durationString[4]}'),
          seconds: int.parse('${durationString[6]}${durationString[7]}'),
        );
      case == 7:
        return Duration(
          hours: int.parse(durationString[0]),
          minutes: int.parse('${durationString[2]}${durationString[3]}'),
          seconds: int.parse('${durationString[5]}${durationString[6]}'),
        );
      case == 5:
        return Duration(
            minutes: int.parse('${durationString[0]}${durationString[1]}'),
            seconds: int.parse('${durationString[3]}${durationString[4]}'));
      case == 4:
        return Duration(
            seconds: int.parse('${durationString[2]}${durationString[3]}'));
      case _:
        return const Duration(seconds: 0);
    }
  }

  @override
  void dispose() {
    musicPlayer.player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    if (musicPlayer.mapDuration.isEmpty) {
      musicPlayer.songList.addAll({widget.title});
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
            Icon(
              Icons.music_video,
              size: width * 0.50,
              color: Colors.white,
            ),
            TextScroll(
              widget.title,
              velocity: const Velocity(pixelsPerSecond: Offset(45, 0)),
              intervalSpaces: 10,
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.05,
              ),
            ),
            SizedBox(height: height * 0.01),
            Text(
              textAlign: TextAlign.center,
              widget.viewCount,
              style: TextStyle(
                  color: const Color.fromARGB(255, 112, 231, 114),
                  fontSize: width * 0.045),
            ),
            SizedBox(height: height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  widget.uploadDateRaw,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 112, 231, 114),
                      fontSize: width * 0.045),
                ),
                Text(
                  textAlign: TextAlign.center,
                  '- ${widget.uploadDate.day}/${widget.uploadDate.month}/${widget.uploadDate.year}',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 112, 231, 114),
                      fontSize: width * 0.045),
                ),
              ],
            ),
            SizedBox(height: height * 0.01),
            // mudar o progress bar para o musicPlayer;
            musicPlayer.progressBar(
              width * 0.80,
              loadingMaster,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                TextButton(
                  onPressed: () async {
                    if (musicPlayer.player.currentIndex == null) {
                      setState(() => loading = true);
                      await musicPlayer.player.setAudioSource(widget.urlSound);
                    }

                    if (musicPlayer.musicaCompletada()) {
                      musicPlayer.player.seek(Duration.zero);
                      setState(() => musicPlayer.musica = Duration.zero);
                    }

                    if (!musicPlayer.player.playing) {
                      musicPlayer.player.play();
                    } else {
                      await musicPlayer.player.pause();
                    }
                    setState(() => loading = false);
                  },
                  child: Stack(
                    children: [
                      Icon(
                        musicPlayer.player.playing
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        size: width * 0.38,
                        color: loading ? Colors.transparent : Colors.green,
                      ),
                      if (loading)
                        Positioned(
                          top: width * 0.04,
                          right: width * 0.04,
                          child: SizedBox(
                            width: width * 0.30,
                            height: height * 0.14,
                            child: const CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    musicPlayer.repeat = !musicPlayer.repeat;
                    setState(() {});
                  },
                  child: Icon(
                    Icons.loop,
                    size: width * 0.12,
                    color: musicPlayer.repeat ? Colors.green : Colors.white,
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
