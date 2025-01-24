import 'package:flutter/material.dart';

import 'constants.dart';

class LoadScreen {
  Future<void> loadingScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                  loadingNormal(size),
                ],
              ),
            ),
          );
        });
  }

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
