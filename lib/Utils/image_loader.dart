import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Classe criada para facilitar o uso do CachedNetworkImage no aplicativo.
class ImageLoader {
  // Cria um CachedNetworkImage com imagem e tamanho personalizado com placeholder e errorWidget pré-definido.
  imageNetwork({required String urlImage, required double size}) {
    return CachedNetworkImage(
      fadeOutDuration: const Duration(milliseconds: 200),
      fadeInDuration: const Duration(milliseconds: 200),
      width: size,
      imageUrl: urlImage,
      placeholder: (context, url) => Icon(
        Icons.music_video,
        size: size,
        color: Colors.white,
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.music_video,
        size: size,
        color: Colors.white,
      ),
    );
  }
}
