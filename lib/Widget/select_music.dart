import 'package:flutter/material.dart';
import 'package:projeto_spotify/Page/play_style.dart';

import '../Utils/groups.dart';
import '../Utils/image_loader.dart';

// Classe criada para o usuário selecionar alguma música para escutar do Mixes.
class SelectMusic extends StatefulWidget {
  final Groups group;

  const SelectMusic({
    required this.group,
    super.key,
  });

  @override
  State<SelectMusic> createState() => _SelectMusicState();
}

class _SelectMusicState extends State<SelectMusic> {
  @override
  Widget build(BuildContext context) {
    // Pega o tamanho da tela e armazena.
    final Size size = MediaQuery.sizeOf(context);
    // Salva o width.
    final double width = size.width;
    // Salva o height.
    final double height = size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Caso o idMusicMap não estiver vazio.
        if (widget.group.idMusicMap.isNotEmpty)
          // Dar um espaço entre os Widget's.
          SizedBox(height: height * 0.01),
        // Widget para scrollar entre a lista de músicas.
        Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
          width: width,
          height: height * 0.818,
          child: ListView.separated(
            itemCount: widget.group.get().length,
            separatorBuilder: (BuildContext context, int index) =>
                SizedBox(height: height * 0.01),
            itemBuilder: (BuildContext context, int index) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      children: [
                        // Imagem da Playlist / Album.
                        SizedBox(
                          width: width * 0.30,
                          height: height * 0.15,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: ImageLoader().imageNetwork(
                                urlImage: widget.group.idMusicMap
                                        .elementAtOrNull(index)?['cover'] ??
                                    '',
                                size: width * 0.31),
                          ),
                        ),
                        SizedBox(
                          width: width * 0.02,
                        ),
                        // Nome da Playlist.
                        Column(
                          children: [
                            // Nome da Playlist / Album.
                            SizedBox(
                              width: width * 0.63,
                              child: Text(
                                widget.group.idMusicMap
                                        .elementAtOrNull(index)?['name'] ??
                                    '',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height * 0.025,
                                ),
                              ),
                            ),
                            // Quantidade de música da Playlist/Album.
                            SizedBox(
                              width: width * 0.63,
                              child: Text(
                                'Tracks: ${widget.group.idMusicMap.elementAt(index)['total']}',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height * 0.025,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Hitbox do tamanho exato da Imagem + Nome da Playlist.
                    TextButton(
                      onPressed: () {
                        // Caso a lista seja diferente de null.
                        if (widget.group.idMusicMap
                                .elementAt(index)['spotify'] !=
                            null) {
                          // Vai para playlist_style.
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PlayStyle(
                                      trackId: widget.group.idMusicMap
                                          .elementAt(index)['spotify']!)));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: SizedBox(
                        width: width,
                        height: height * 0.128,
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
