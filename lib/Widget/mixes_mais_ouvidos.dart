import 'package:flutter/material.dart';
import 'package:projeto_spotify/Widget/playlist_style.dart';
import 'package:text_scroll/text_scroll.dart';

import '../Utils/groups.dart';

class MixesMaisOuvidos extends StatefulWidget {
  final Groups group;
  const MixesMaisOuvidos({required this.group, super.key});

  @override
  State<MixesMaisOuvidos> createState() => _MixesMaisOuvidosState();
}

class _MixesMaisOuvidosState extends State<MixesMaisOuvidos> {
  Map<int, Map<String, String>> mapMixesInfo = {};

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    if (widget.group.getMap('mixes').isNotEmpty) {
      mapMixesInfo = widget.group.getMap('mixes');
      setState(() => isLoading = false);
    }
    if (mapMixesInfo.isEmpty) {
      widget.group.loadMap('mixes').then((value) {
        mapMixesInfo = widget.group.getMap('mixes');
        if (mapMixesInfo.isNotEmpty) {
          setState(() => isLoading = false);
        }
      });
    }

    return isLoading
        ? SizedBox(
            height: height * 0.30,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.green),
            ))
        : Column(
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
                      child: !isLoading
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  width: width * 0.45,
                                  height: height * 0.22,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: Image.network(
                                        mapMixesInfo[index]!['Image']!),
                                  ),
                                ),
                                Positioned(
                                  top: width * 0.45,
                                  left: height * 0.01,
                                  child: SizedBox(
                                    width: width * 0.4,
                                    child: TextScroll(
                                      mapMixesInfo[index]!['Name']!,
                                      velocity: const Velocity(
                                          pixelsPerSecond: Offset(45, 0)),
                                      intervalSpaces: 10,
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
                                                trackId: mapMixesInfo[index]![
                                                    'ID']!)));
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
