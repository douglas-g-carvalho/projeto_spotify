import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' as sptf;
import 'package:projeto_spotify/Utils/music_player.dart';

import 'whats_playing.dart';

import '../Utils/image_loader.dart';
import '../Utils/load_screen.dart';
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

  bool isPlaying = false;

  void loadingMaster(bool value) {
    setState(() => loading = value);
  }

  @override
  void initState() {
    final credentials =
        sptf.SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = sptf.SpotifyApi(credentials);

    spotify.playlists.get(widget.trackId).then((value) {
      musicPlayer.playlistName.add(value.name!);
      musicPlayer.artistImage.add(value.images!.first.url!);

      value.tracks?.itemsNative?.forEach((value) {
        List<String> saveArtistName = [];

        musicPlayer.songList.add(value['track']['name']);
        musicPlayer.imageList.add(value['track']['album']['images'][0]['url']);

        value['track']['artists'].forEach((artistas) {
          saveArtistName.add(artistas['name']);
        });
        musicPlayer.artistName.addAll({value['track']['name']: saveArtistName});
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
          musicPlayer.playlistName.elementAtOrNull(0) ?? '',
          style: TextStyle(color: Colors.white, fontSize: width * 0.055),
        ),
      ),
      body: musicPlayer.songList.isEmpty
          ? LoadScreen().loadingNormal(size)
          : Stack(
              children: [
                const SizedBox(height: double.infinity),
                Container(
                  decoration: const BoxDecoration(color: Colors.black),
                  padding: const EdgeInsets.all(5),
                  width: double.infinity,
                  height: isPlaying ? height * 0.727 : double.infinity,
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
                                        color: Colors.white,
                                        fontSize: width * 0.05),
                                  ),
                                ),
                                SizedBox(width: width * 0.02),
                                SizedBox(
                                  width: width * 0.20,
                                  height: height * 0.10,
                                  child: ImageLoader().imageNetwork(
                                      urlImage: musicPlayer.imageList[index],
                                      size: width * 0.21),
                                ),
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
                                      child: Text(
                                        musicPlayer.songList.elementAt(index),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: height * 0.025,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: index < 9
                                          ? width * 0.50
                                          : index < 99
                                              ? width * 0.47
                                              : width * 0.45,
                                      child: Text(
                                        musicPlayer.textArtists(
                                            musicPlayer.artistName[musicPlayer
                                                .songList
                                                .elementAt(index)]!),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: height * 0.025,
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

                                    if (musicPlayer.songIndex != index) {
                                      musicPlayer.player.pause();
                                    }

                                    musicPlayer.songIndex = index;

                                    await musicPlayer.changeMusic();

                                    musicPlayer.play();
                                    isPlaying = true;
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
                                            : Constants.color,
                                        size: (width + height) * 0.04,
                                      ),
                                      if (loading == true &&
                                          musicPlayer.songList
                                                  .elementAt(index) ==
                                              musicPlayer.actualSong)
                                        Positioned(
                                          top: height * 0.008,
                                          right: width * 0.015,
                                          child: SizedBox(
                                            width: ((width + height) * 0.03),
                                            height: ((width + height) * 0.03),
                                            child:
                                                const CircularProgressIndicator(
                                                    color: Constants.color),
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
                if (isPlaying)
                  Positioned(
                    bottom: 0,
                    child: WhatsPlaying(
                      nameMusic:
                          musicPlayer.songList.elementAt(musicPlayer.songIndex),
                      imageMusic: musicPlayer.imageList[musicPlayer.songIndex],
                      artistName: musicPlayer.artistName[musicPlayer.songList
                          .elementAt(musicPlayer.songIndex)]!,
                      musicPlayer: musicPlayer,
                      loading: loading,
                      loadingMaster: loadingMaster,
                      duration: musicPlayer.mapDuration[musicPlayer.songList
                              .elementAt(musicPlayer.songIndex)] ??
                          Duration.zero,
                      stopWidget: () {
                        setState(() {
                          isPlaying = false;
                          musicPlayer.player.stop();
                        });
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
