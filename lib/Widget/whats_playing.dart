import 'package:flutter/material.dart';

import '../Utils/constants.dart';
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
        color: const Color.fromARGB(255, 54, 35, 58),
        border: Border.all(
          color: Constants.color,
          width: width * 0.005,
        ),
      ),
      height: height * 0.21,
      width: width * 0.995,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                  switch (widget.musicPlayer.repeatType) {
                    case 0:
                      widget.musicPlayer.autoPlay = true;
                      widget.musicPlayer.repeatType += 1;
                    case 1:
                      widget.musicPlayer.repeat = true;
                      widget.musicPlayer.autoPlay = false;
                      widget.musicPlayer.repeatType += 1;
                    case 2:
                      widget.musicPlayer.repeat = false;
                      widget.musicPlayer.repeatType = 0;
                  }
    
                  setState(() {});
                },
                child: Icon(
                  widget.musicPlayer.repeatType == 0
                      ? Icons.repeat
                      : widget.musicPlayer.repeatType == 1
                          ? Icons.repeat
                          : Icons.repeat_one,
                  size: width * 0.078,
                  color: widget.musicPlayer.repeatType == 0
                      ? Colors.white
                      : widget.musicPlayer.repeatType == 1
                          ? Constants.color
                          : Constants.color,
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
                      ? Constants.color
                      : Colors.white,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child:
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ImageLoader().imageNetwork(
                  urlImage: widget.imageMusic, size: width * 0.25),
              SizedBox(width: width * 0.03),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: width * 0.44,
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
                    width: width * 0.44,
                    child: Text(
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      widget.musicPlayer.textArtists(widget.artistName),
                      style: TextStyle(
                          color: Colors.white, fontSize: width * 0.045),
                    ),
                  ),
                  widget.musicPlayer.progressBar(
                    size.width * 0.55,
                    widget.loadingMaster,
                  ),
                ],
              ),
              SizedBox(width: width * 0.03),
              Stack(
                children: [
                  widget.loading
                      ? SizedBox(
                          width: ((width + height) * 0.047),
                          height: ((width + height) * 0.047),
                          child: const CircularProgressIndicator(
                              color: Constants.color))
                      : Icon(
                          (widget.musicPlayer.player.playing)
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Constants.color,
                          size: width * 0.144,
                        ),
                  TextButton(
                      style: ElevatedButton.styleFrom(
                        splashFactory: widget.loading
                            ? NoSplash.splashFactory
                            : InkSplash.splashFactory,
                        minimumSize: Size(0.1, 0.1),
                      ),
                      onPressed: () {
                        if (!widget.loading) {
                          if (widget.musicPlayer.musicaCompletada()) {
                            widget.musicPlayer.player.seek(Duration.zero);
                            setState(() =>
                                widget.musicPlayer.musica = Duration.zero);
                          }
    
                          widget.loadingMaster(true);
    
                          widget.musicPlayer.play().then((value) {
                            widget.loadingMaster(false);
                          });
                        }
                      },
                      child: SizedBox(
                        width: width * 0.09,
                        height: height * 0.055,
                      )),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
