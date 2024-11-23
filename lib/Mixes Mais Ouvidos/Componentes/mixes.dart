import 'package:flutter/material.dart';

import 'text_mix.dart';

class Mixes {
  Widget mixes({String? group, bool? extra, String? teste}) {
    Widget imagem;

    try {
      imagem = Image.network(teste!);
    } catch (e) {
      imagem = const Placeholder(color: Colors.transparent);
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: imagem,
        ),
        if (group != null)
          Positioned(
            top: group.length > 20 ? 130 : 140,
            left: 5,
            child: SizedBox(
              width: 165,
              child: TextMix().textoMixes(group),
            ),
          ),
        if (extra != null)
          Positioned(
            top: 5,
            left: 5,
            child: SizedBox(
              width: 15,
              height: 15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  color: Colors.white,
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Spotify_logo_without_text.svg/2000px-Spotify_logo_without_text.svg.png',
                ),
              ),
            ),
          ),
      ],
    );
  }
}
