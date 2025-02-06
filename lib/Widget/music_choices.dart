import 'package:flutter/material.dart';
import 'package:projeto_spotify/Widget/play_music.dart';

import '../Utils/image_loader.dart';

// Classe com imagem e nome da Playlist da Lista.
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
    // Pega o tamanho da tela e armazena.
    final Size size = MediaQuery.sizeOf(context);
    // Salva o width.
    final double width = size.width;
    // Salva o height.
    final double height = size.height;

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
              // Imagem e Nome da Playlist.
              Row(
                children: [
                  // Imagem da Playlist.
                  ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: ImageLoader().imageNetwork(
                          urlImage: icon ?? '', size: width * 0.165)),
                  // Nome da Playlist.
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        texto ?? '',
                        overflow: TextOverflow.ellipsis,
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
              // TextButton com tamanho da Imagem e Nome da Playlist.
              TextButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                ),
                onPressed: () {
                  // Se spotify não for nulo.
                  if (spotify != null) {
                    // Vai para play_music.
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
