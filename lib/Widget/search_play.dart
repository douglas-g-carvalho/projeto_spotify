import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
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
  AudioPlayer player = AudioPlayer();
  bool loading = false;

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

  Future<void> play() async {
    if (player.currentIndex == null) {
      player.setAudioSource(widget.urlSound);
    }

    if (!player.playing) {
      setState(() => loading = true);

      await player.play();

      setState(() => loading = false);
    } else {
      await player.pause();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

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
              size: width * 0.95,
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
            SizedBox(
              width: width * 0.80,
              child: StreamBuilder(
                stream: player.positionStream,
                builder: (context, data) {
                  return ProgressBar(
                    progress: data.data ?? const Duration(seconds: 0),
                    total: stringToDuration(widget.duration),
                    buffered: player.bufferedPosition,
                    bufferedBarColor: Colors.grey,
                    baseBarColor: Colors.white,
                    thumbColor: Colors.green[700],
                    thumbRadius: 7,
                    timeLabelTextStyle: const TextStyle(color: Colors.white),
                    progressBarColor: Colors.green[700],
                    onSeek: (duration) async {
                      await player.seek(duration);
                    },
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () async {
                await play();
              },
              child: Stack(
                children: [
                  Icon(
                    player.playing
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: width * 0.38,
                    color: loading ? Colors.transparent : Colors.green,
                  ),
                  Positioned(
                    top: width * 0.04,
                    right: width * 0.04,
                    child: SizedBox(
                      width: width * 0.3,
                      height: height * 0.15,
                      child: const CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
