import 'package:flutter/material.dart';

class BasicChoices extends StatelessWidget {
  final List<bool> hud;
  final Function(List<bool>) changeHud;
  const BasicChoices({super.key, required this.hud, required this.changeHud});


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.account_circle_outlined,
          color: Colors.white,
          size: 50,
        ),
        const SizedBox(width: 5),
        TextButton(
          style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: hud[0]
                  ? const Color.fromARGB(255, 97, 216, 101)
                  : Colors.grey[800]),
          onPressed: () {
            changeHud([true, false, false]);
          },
          child: Text(
            'Tudo',
            style: TextStyle(
              color: hud[0] ? Colors.black : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 5),
        TextButton(
          style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: hud[1]
                  ? const Color.fromARGB(255, 97, 216, 101)
                  : Colors.grey[800]),
          onPressed: () {
            changeHud([false, true, false]);
          },
          child: Text(
            'Música',
            style: TextStyle(
              color: hud[1] ? Colors.black : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 5),
        TextButton(
          style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: hud[2]
                  ? const Color.fromARGB(255, 97, 216, 101)
                  : Colors.grey[800]),
          onPressed: () {
            changeHud([false, false, true]);
          },
          child: Text(
            'Podcasts',
            style: TextStyle(
              color: hud[2] ? Colors.black : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
