import 'package:flutter/material.dart';

class LoadScreen {
  Future<void> loadingScreen(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return const AlertDialog(
            backgroundColor: Colors.transparent,
            actions: [
              Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            ],
          );
        });
  }
}
