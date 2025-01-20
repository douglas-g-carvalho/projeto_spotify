import 'package:flutter/material.dart';
import 'package:projeto_spotify/Widget/play_music.dart';

import '../Utils/image_loader.dart';

class MusicChoices extends StatelessWidget {
  final String? texto;
  final String? icon;
  final String? spotify;

  const MusicChoices({
    super.key,
    required this.texto,
    required this.icon,
    required this.spotify,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: width * 0.5,
          height: height * 0.075,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              shape: BoxShape.rectangle,
              color: Colors.grey[800]),
          child: Stack(
            children: [
              Row(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: ImageLoader().imageNetwork(
                          urlImage: icon ?? '', size: width * 0.165)),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        texto ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: height * 0.02,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                ),
                onPressed: () {
                  if (spotify != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PlayMusic(trackId: spotify!)));
                  }
                },
                child: SizedBox(
                  width: width * 0.5,
                  height: height * 0.06,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
