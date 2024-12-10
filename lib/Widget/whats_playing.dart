import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';

class WhatsPlaying extends StatefulWidget {
  final String nameMusic;
  final String imageMusic;
  final String descriptionMusic;
  final Function(String, String, [bool]) playBottom;
  final AudioPlayer player;
  final bool otherMusic;
  final Duration duration;

  const WhatsPlaying({
    super.key,
    required this.nameMusic,
    required this.imageMusic,
    required this.descriptionMusic,
    required this.playBottom,
    required this.player,
    required this.otherMusic,
    required this.duration,
  });

  @override
  State<WhatsPlaying> createState() => _WhatsPlayingState();
}

class _WhatsPlayingState extends State<WhatsPlaying> {
  Duration? timeStamp = const Duration(seconds: 0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    if (widget.otherMusic) {
      timeStamp = const Duration(seconds: 0);
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 21, 39, 29),
        border: Border.all(
          color: Colors.green,
        ),
      ),
      height: height * 0.13,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.network(
            widget.imageMusic,
            width: width * 0.25,
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: width * 0.482,
                  child: Text(
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    widget.nameMusic,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                SizedBox(
                  width: width * 0.482,
                  child: Text(
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    widget.descriptionMusic,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.482,
                  child: StreamBuilder(
                    stream: widget.player.onPositionChanged,
                    builder: (context, data) {
                      timeStamp = data.data;
                      return ProgressBar(
                        progress: timeStamp ?? const Duration(seconds: 0),
                        total: widget.duration,
                        bufferedBarColor: Colors.grey,
                        baseBarColor: const Color.fromARGB(221, 197, 197, 197),
                        thumbColor: Colors.green,
                        thumbRadius: 7,
                        timeLabelTextStyle:
                            const TextStyle(color: Colors.white),
                        progressBarColor: Colors.green[900],
                        onSeek: (duration) async {
                          await widget.player.seek(duration);
                          await widget.player.resume();
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await widget.playBottom(
                  widget.nameMusic, widget.descriptionMusic);
              setState(() {});
            },
            child: Stack(
              children: [
                widget.otherMusic
                    ? SizedBox(
                        width: ((width + height) * 0.05),
                        height: ((width + height) * 0.05),
                        child: const CircularProgressIndicator(
                            color: Colors.green))
                    : Icon(
                        (widget.player.state == PlayerState.playing)
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.green,
                        size: width * 0.15,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
