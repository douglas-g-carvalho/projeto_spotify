import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as sptf;

import 'package:projeto_spotify/Widget/music_player.dart';
import 'whats_playing.dart';

import '../Utils/constants.dart';

class PlaylistStyle extends StatefulWidget {
  final String trackId;
  const PlaylistStyle({super.key, required this.trackId});

  @override
  State<PlaylistStyle> createState() => _PlaylistStyleState();
}

class _PlaylistStyleState extends State<PlaylistStyle> {
  final musicPlayer = MusicPlayer();

  bool loading = false;
  bool otherMusic = false;

  @override
  void initState() {
    final credentials =
        sptf.SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = sptf.SpotifyApi(credentials);

    spotify.playlists.get(widget.trackId).then((value) {
      musicPlayer.artistName.add(value.name!);
      musicPlayer.artistImage.add(value.images!.first.url!);

      value.tracks?.itemsNative?.forEach((value) {
        musicPlayer.songList.add(value['track']['name']);
        musicPlayer.imageList.add(value['track']['album']['images'][0]['url']);
        musicPlayer.descriptionList.add(value['track']['artists'][0]['name']);
      });

      setState(() {});
    });

    super.initState();
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

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          musicPlayer.artistName.elementAtOrNull(0) ?? '',
          style: TextStyle(color: Colors.white, fontSize: width * 0.055),
        ),
      ),
      body: Stack(
        children: [
          const SizedBox(height: double.infinity),
          Container(
            decoration: const BoxDecoration(color: Colors.black),
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            height: musicPlayer.player.currentIndex != null
                ? height * 0.769
                : double.infinity,
            child: ListView.separated(
              itemCount: musicPlayer.songList.length,
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: height * 0.01),
              itemBuilder: (BuildContext context, int index) {
                return musicPlayer.songList.isNotEmpty
                    ? Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: width * 0.05),
                            ),
                          ),
                          SizedBox(width: width * 0.02),
                          SizedBox(
                              width: width * 0.20,
                              height: height * 0.10,
                              child:
                                  Image.network(musicPlayer.imageList[index])),
                          SizedBox(width: width * 0.02),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: index < 9
                                    ? width * 0.50
                                    : index < 99
                                        ? width * 0.47
                                        : width * 0.45,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    musicPlayer.songList.elementAt(index),
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: index < 9
                                    ? width * 0.50
                                    : index < 99
                                        ? width * 0.47
                                        : width * 0.45,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    musicPlayer.descriptionList
                                        .elementAt(index),
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                            ),
                            onPressed: () async {
                              if (loading == true) {
                                return;
                              }

                              setState(() => loading = true);

                              musicPlayer.songIndex = index;

                              // caso o nome da música não esteja na lista mapSongURL
                              // e seja diferente da que esta sendo tocada no momento
                              if (!musicPlayer.mapSongURL.containsKey(
                                  musicPlayer.songList.elementAt(index))) {
                                // muda a música atual para a nova;
                                musicPlayer.actualSong =
                                    musicPlayer.songList.elementAt(index);
                                // para a música que está tocando
                                await musicPlayer.player.stop();
                                // coloca salva o index dá música e procura e salva no mapSongURL
                                // e a toca
                                await musicPlayer.getUrlMusic(
                                    musicPlayer.songList.elementAt(index),
                                    musicPlayer.descriptionList
                                        .elementAt(index));
                              } else if (musicPlayer.songList
                                      .elementAt(index) !=
                                  musicPlayer.actualSong) {
                                // muda a música atual para a nova;
                                musicPlayer.actualSong =
                                    musicPlayer.songList.elementAt(index);
                                // caso a música esteja no mapSongURL e não é a que está tocando,
                                // para a música que está tocando
                                await musicPlayer.player.stop();
                                // inicia a música nova
                                await musicPlayer.setAudioSource(
                                    musicPlayer.songList.elementAt(index));
                              }

                              musicPlayer.play();
                              setState(() => loading = false);
                            },
                            child: Stack(
                              children: [
                                Icon(
                                  (musicPlayer.player.playing &&
                                          musicPlayer.songList
                                                  .elementAt(index) ==
                                              musicPlayer.actualSong)
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  color: loading
                                      ? Colors.transparent
                                      : Colors.green,
                                  size: (width + height) * 0.04,
                                ),
                                if (loading == true &&
                                    musicPlayer.songList.elementAt(index) ==
                                        musicPlayer.actualSong)
                                  Positioned(
                                    top: height * 0.008,
                                    right: width * 0.015,
                                    child: SizedBox(
                                      width: ((width + height) * 0.03),
                                      height: ((width + height) * 0.03),
                                      child: const CircularProgressIndicator(
                                          color: Colors.green),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const Placeholder(color: Colors.transparent);
              },
            ),
          ),
          if (musicPlayer.player.currentIndex != null)
            Positioned(
              bottom: 0,
              child: WhatsPlaying(
                nameMusic:
                    musicPlayer.songList.elementAt(musicPlayer.songIndex),
                imageMusic: musicPlayer.imageList[musicPlayer.songIndex],
                descriptionMusic: musicPlayer.descriptionList
                    .elementAt(musicPlayer.songIndex),
                musicPlayer: musicPlayer,
                loading: loading,
                duration: musicPlayer.mapDuration[musicPlayer.songList
                        .elementAt(musicPlayer.songIndex)] ??
                    Duration.zero,
              ),
            ),
        ],
      ),
    );
  }
}
