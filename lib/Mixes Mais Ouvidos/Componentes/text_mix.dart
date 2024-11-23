import 'package:flutter/material.dart';

class TextMix {
  Widget textoMixes(String group) {
    return Stack(
      children: [
        Text(
          group,
          style: TextStyle(
            fontSize: 14,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 5
              ..color = Colors.black,
          ),
        ),
        Text(
          group,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
