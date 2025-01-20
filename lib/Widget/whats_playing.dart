import 'package:flutter/material.dart';

import '../Utils/music_player.dart';
import '../Utils/image_loader.dart';

class WhatsPlaying extends StatefulWidget {
  final String nameMusic;
  final String imageMusic;
  final List<String> artistName;
  final MusicPlayer musicPlayer;
  final bool loading;
  final Function(bool) loadingMaster;
  final Duration duration;
  final Function stopWidget;

  const WhatsPlaying({
    super.key,
    required this.nameMusic,
    required this.imageMusic,
    required this.artistName,
    required this.musicPlayer,
    required this.loading,
    required this.loadingMaster,
    required this.duration,
    required this.stopWidget,
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
      height: height * 0.21,
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    widget.stopWidget();
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: width * 0.078,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.musicPlayer.repeat = !widget.musicPlayer.repeat;
                    setState(() {});
                  },
                  child: Icon(
                    widget.musicPlayer.repeat ? Icons.repeat_one : Icons.repeat,
                    size: width * 0.078,
                    color:
                        widget.musicPlayer.repeat ? Colors.green : Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.musicPlayer.shuffle = !widget.musicPlayer.shuffle;
                    setState(() {});
                  },
                  child: Icon(
                    Icons.shuffle,
                    size: width * 0.078,
                    color: widget.musicPlayer.shuffle
                        ? Colors.green
                        : Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ImageLoader().imageNetwork(
                    urlImage: widget.imageMusic, size: width * 0.25),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width * 0.5,
                        child: Text(
                          widget.nameMusic,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: height * 0.023,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.5,
                        child: Text(
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          widget.musicPlayer.textArtists(widget.artistName),
                          style: TextStyle(
                              color: Colors.white, fontSize: width * 0.045),
                        ),
                      ),
                      widget.musicPlayer.progressBar(
                        size.width * 0.6,
                        widget.loadingMaster,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.musicPlayer.musicaCompletada()) {
                      widget.musicPlayer.player.seek(Duration.zero);
                      setState(() => widget.musicPlayer.musica = Duration.zero);
                    }

                    widget.loadingMaster(true);

                    widget.musicPlayer.play().then((value) {
                      widget.loadingMaster(false);
                    });
                  },
                  child: Stack(
                    children: [
                      widget.loading
                          ? SizedBox(
                              width: ((width + height) * 0.035),
                              height: ((width + height) * 0.035),
                              child: const CircularProgressIndicator(
                                  color: Colors.green))
                          : Icon(
                              (widget.musicPlayer.player.playing)
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.green,
                              size: width * 0.12,
                            ),
                    ],
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
