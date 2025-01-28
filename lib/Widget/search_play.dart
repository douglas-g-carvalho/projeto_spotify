import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:projeto_spotify/Utils/music_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Utils/constants.dart';

class SearchPlay extends StatefulWidget {
  final VideoId id;
  final String title;
  final String author;
  final String viewCount;
  final String uploadDate;
  final String uploadDateRaw;
  final String duration;

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
  MusicPlayer musicPlayer = MusicPlayer();
  bool loading = false;

  dynamic audioUrl;

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

  Future<void> audioIsOn() async {
    if (audioUrl == null) {
      var manifest =
          await YoutubeExplode().videos.streamsClient.getManifest(widget.id);
      audioUrl = manifest.audioOnly.last.url;

      await musicPlayer.player.setAudioSource(AudioSource.uri(audioUrl));
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
            if (widget.uploadDate == '- Sem data')
              SizedBox(height: height * 0.001),
            Icon(
              Icons.music_video,
              size: width * 0.75,
              color: Colors.white,
            ),
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
            SizedBox(height: height * 0.01),
            Text(
              textAlign: TextAlign.center,
              widget.viewCount,
              style: TextStyle(color: Constants.color, fontSize: width * 0.06),
            ),
            SizedBox(height: height * 0.01),
            if (widget.uploadDate != '- Sem data')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    widget.uploadDateRaw,
                    style: TextStyle(
                        color: Constants.color, fontSize: width * 0.06),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    widget.uploadDate,
                    style: TextStyle(
                        color: Constants.color, fontSize: width * 0.06),
                  ),
                ],
              ),
            SizedBox(height: height * 0.01),
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
                    setState(() => loading = true);
                    await audioIsOn();

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
                TextButton(
                  onPressed: () {
                    musicPlayer.repeat = !musicPlayer.repeat;
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
