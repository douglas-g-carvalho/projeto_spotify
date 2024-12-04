import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SearchPlay extends StatefulWidget {
  final String title;
  final String author;
  final String viewCount;
  final DateTime uploadDate;
  final String uploadDateRaw;
  final String duration;
  final UrlSource urlSound;

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
  final player = AudioPlayer();

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
            Text(
              textAlign: TextAlign.center,
              widget.title,
              style: TextStyle(color: Colors.white, fontSize: width * 0.05),
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
            SizedBox(
              width: width * 0.80,
              child: StreamBuilder(
                stream: player.onPositionChanged,
                builder: (context, data) {
                  return ProgressBar(
                    progress: const Duration(seconds: 0),
                    total: stringToDuration(widget.duration),
                    bufferedBarColor: Colors.grey,
                    baseBarColor: Colors.white,
                    thumbColor: Colors.green,
                    thumbRadius: 7,
                    timeLabelTextStyle: const TextStyle(color: Colors.white),
                    progressBarColor: Colors.green[900],
                    onSeek: (duration) {
                      player.seek(duration);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
