import 'package:flutter/material.dart';
import 'package:projeto_spotify/Widget/playlist_style.dart';

import '../Utils/groups.dart';
import '../Utils/image_loader.dart';

class MixesMaisOuvidos extends StatefulWidget {
  final Groups group;
  final Set<Map<String, String>> mapMixesInfo;

  const MixesMaisOuvidos({
    required this.group,
    required this.mapMixesInfo,
    super.key,
  });

  @override
  State<MixesMaisOuvidos> createState() => _MixesMaisOuvidosState();
}

class _MixesMaisOuvidosState extends State<MixesMaisOuvidos> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Column(
      children: [
        Text(
          'Alguns álbuns para você',
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
            itemCount: widget.group.get('mixes').length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 5),
            itemBuilder: (BuildContext context, int index) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: width * 0.45,
                      height: height * 0.22,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: ImageLoader().imageNetwork(
                            urlImage:
                                widget.mapMixesInfo.elementAt(index)['cover']!,
                            size: width * 0.45),
                      ),
                    ),
                    Positioned(
                      top: width * 0.45,
                      left: height * 0.01,
                      child: SizedBox(
                        width: width * 0.4,
                        child: Text(
                          widget.mapMixesInfo.elementAt(index)['name']!,
                          overflow: TextOverflow.ellipsis,
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
                                    trackId: widget.mapMixesInfo
                                        .elementAt(index)['spotify']!)));
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
