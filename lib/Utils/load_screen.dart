import 'package:flutter/material.dart';

import 'constants.dart';

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
