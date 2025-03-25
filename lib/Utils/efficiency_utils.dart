import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:cached_network_image/cached_network_image.dart';

// Classe criada para facilitar a navegação.
class AppRoutes {
  static const login = '/';
  static const inicio = '/inicio';
  static const buscar = '/buscar';
}

// Classe para facilitar o uso da Database do Firebase.
class Database {
  // Referência para facilitar o uso da Database.
  final dbRefInfo = FirebaseDatabase.instance.ref().child('Informações');

  // Função para facilitar o ato de adicionar ou atualizar o conteúdo no Firebase.
  DatabaseReference updateDataBase() {
    return dbRefInfo.child(FirebaseAuth.instance.currentUser!.uid);
  }
}

// Classe criada para guardar informações estáticas.
class Constants {
  static const String clientId = 'bfa437e0b5da4af7800d946b894bb019';
  static const String clientSecret = '522f553b7e6a42b2b79a20db93542f73';

  static const color = Colors.purple;
}

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

// Classe criada para facilitar o uso das Telas de Carregamento.
class LoadScreen {
  // Função que faz a tela de carregamento.
  Future<void> loadingScreen(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return PopScope(
            canPop: false,
            child: SingleChildScrollView(
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                actions: [
                  loadingNormal(MediaQuery.of(context).size),
                ],
              ),
            ),
          );
        });
  }

  // Widget com ícone de carregamento.
  Widget loadingNormal(Size size) {
    return Center(
      heightFactor: 16,
      child: SizedBox(
        width: size.width * 0.10,
        height: size.height * 0.05,
        child: const CircularProgressIndicator(
          color: Constants.color,
        ),
      ),
    );
  }
}

// Classe criada para notificar o úsuario que um erro aconteceu.
class ErrorMessage {
  // Função para mostrar um erro na parte de baixo da tela.
  Future<void> bottomSheetError(
      {required String texto,
      required Size size,
      required BuildContext context}) {
    return showModalBottomSheet(
        backgroundColor: Colors.red[900],
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return SizedBox(
            height: size.height * 0.063,
            width: size.width,
            child: Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.height * 0.025,
                color: Colors.white,
              ),
            ),
          );
        });
  }
}

class BlockScreen {
  Future<void> block(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: Center(
            child: SingleChildScrollView(
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Dismissible(
                        key: ValueKey<int>(0),
                        onDismissed: (direction) => Navigator.of(context).pop(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: size.width * 0.10,
                            ),
                            SizedBox(width: size.width * 0.03),
                            Container(
                              width: size.width * 0.15,
                              height: size.height * 0.075,
                              decoration: BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: Icon(
                                Icons.lock,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: size.width * 0.10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
