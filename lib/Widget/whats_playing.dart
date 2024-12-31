import 'package:flutter/material.dart';
import 'package:projeto_spotify/Widget/music_player.dart';

class WhatsPlaying extends StatefulWidget {
  final String nameMusic;
  final String imageMusic;
  final String descriptionMusic;
  final MusicPlayer musicPlayer;
  final bool loading;
  final Duration duration;

  const WhatsPlaying({
    super.key,
    required this.nameMusic,
    required this.imageMusic,
    required this.descriptionMusic,
    required this.musicPlayer,
    required this.loading,
    required this.duration,
  });

  @override
  State<WhatsPlaying> createState() => _WhatsPlayingState();
}

class _WhatsPlayingState extends State<WhatsPlaying> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

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
                widget.musicPlayer
                    .progressBar(size.width * 0.482, widget.duration),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              if (widget.musicPlayer.loop == false) {
                widget.musicPlayer.loop = true;
              }
              await widget.musicPlayer.play();
              setState(() {});
            },
            child: Stack(
              children: [
                widget.loading
                    ? SizedBox(
                        width: ((width + height) * 0.05),
                        height: ((width + height) * 0.05),
                        child: const CircularProgressIndicator(
                            color: Colors.green))
                    : Icon(
                        (widget.musicPlayer.player.playing)
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
