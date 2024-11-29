import 'package:flutter/material.dart';
import 'package:projeto_spotify/Widget/playlist_style.dart';

import '../Utils/constants.dart';
import 'package:spotify/spotify.dart' as sptf;

class MixesMaisOuvidos extends StatefulWidget {
  const MixesMaisOuvidos({super.key});

  @override
  State<MixesMaisOuvidos> createState() => _MixesMaisOuvidosState();
}

class _MixesMaisOuvidosState extends State<MixesMaisOuvidos> {
  final List<String> listGroups = [
 '6G4O7YRLjTk4T4VPa4fDAM',
 '7w13RcdObCa0WvQrjVJDfp',
 '5z2dTZUjDD90wM4Z9youwS',
  ];

  List<String> artistImage = [];
  List<String> playlistName = [];
  List<String> listID = [];

  @override
  void initState() {
    final credentials =
        sptf.SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = sptf.SpotifyApi(credentials);
    for (int index = 0; index != listGroups.length; index++) {
      spotify.playlists.get(listGroups[index]).then((value) {
        artistImage.add(value.images!.first.url!);
        playlistName.add(value.name!);
        listID.add(value.id!);
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Column(
      children: [
        Text(
          artistImage.length == listGroups.length
              ? 'Alguns álbuns para você'
              : '',
          style: TextStyle(color: Colors.white, fontSize: height * 0.03),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
          width: double.infinity,
          height: height * 0.30,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: listGroups.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 5),
            itemBuilder: (BuildContext context, int index) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: artistImage.length == listGroups.length
                    ? Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            width: width * 0.45,
                            height: height * 0.22,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.network(artistImage[index]),
                            ),
                          ),
                          Positioned(
                            top: width * 0.45,
                            left: height * 0.01,
                            child: SizedBox(
                              width: width * 0.4,
                              child: Text(
                                overflow: TextOverflow.clip,
                                textAlign: TextAlign.center,
                                playlistName[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height * 0.025,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => PlaylistStyle(
                                          trackId: listID[index])));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: SizedBox(
                              width: width * 0.38,
                              height: height * 0.20,
                            ),
                          ),
                        ],
                      )
                    : const Placeholder(color: Colors.transparent),
              );
            },
          ),
        ),
      ],
    );
  }
}
