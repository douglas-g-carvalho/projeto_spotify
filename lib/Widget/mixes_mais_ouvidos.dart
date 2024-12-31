import 'package:flutter/material.dart';
import 'package:projeto_spotify/Widget/playlist_style.dart';

import 'package:spotify/spotify.dart' as sptf;

import '../Utils/constants.dart';
import '../Utils/groups.dart';

class MixesMaisOuvidos extends StatefulWidget {
  final Groups group;
  const MixesMaisOuvidos({required this.group, super.key});

  @override
  State<MixesMaisOuvidos> createState() => _MixesMaisOuvidosState();
}

class _MixesMaisOuvidosState extends State<MixesMaisOuvidos> {
  late List<String> mixes = widget.group.getMixes();

  Map<int, Map<String, String>> mapInfo = {};

  @override
  void initState() {
    final credentials =
        sptf.SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = sptf.SpotifyApi(credentials);

    if (widget.group.getMapInfo().isNotEmpty) {
      mapInfo = widget.group.getMapInfo();
      return;
    }

    for (int index = 0; index != mixes.length; index++) {
      spotify.playlists.get(mixes[index]).then((value) {
        widget.group.addMapInfo(index, 'ID', value.id!);
        widget.group.addMapInfo(index, 'Name', value.name!);
        widget.group.addMapInfo(index, 'Image', value.images!.first.url!);

        mapInfo = widget.group.getMapInfo();
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
          mapInfo.length == mixes.length ? 'Alguns álbuns para você' : '',
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
            itemCount: mixes.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 5),
            itemBuilder: (BuildContext context, int index) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: mapInfo.length == mixes.length
                    ? Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            width: width * 0.45,
                            height: height * 0.22,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.network(mapInfo[index]!['Image']!),
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
                                mapInfo[index]!['Name']!,
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
                                          trackId: mapInfo[index]!['ID']!)));
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
