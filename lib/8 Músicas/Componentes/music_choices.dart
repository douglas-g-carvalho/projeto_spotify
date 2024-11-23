import 'package:flutter/material.dart';
import 'package:projeto_spotify/Tocar%20Playlist/play_playlist.dart';

class MusicChoices extends StatelessWidget {
  final String texto;
  final String icon;
  final String spotify;

  const MusicChoices({
    super.key,
    required this.texto,
    required this.icon,
    required this.spotify,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          height: 60,
          width: 200,
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
                      child: Image.network(icon)),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        texto,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PlayPlaylist(trackId: spotify)));
                },
                child: const SizedBox(
                  width: 170,
                  height: 60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
