import 'package:flutter/material.dart';
import 'package:projeto_spotify/Widget/mixes_mais_ouvidos.dart';

import '../Widget/basic_choices.dart';
import '../Widget/eighty_music.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  List<bool> hudChoice = [true, false, false];

  @override
  Widget build(BuildContext context) {
    void change(List<bool> hud) {
      setState(() => hudChoice = hud);
    }

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedIconTheme: const IconThemeData(color: Colors.green),
        unselectedIconTheme: const IconThemeData(color: Colors.white),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        ],
        onTap: (value) {
          switch (value) {
            case 0:
              Navigator.pushNamed(context, '/');
            case 1:
              Navigator.pushNamed(context, '/buscar');
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BasicChoices(hud: hudChoice, changeHud: change),
              const SizedBox(height: 10),
              if (hudChoice[0] || hudChoice[1])
                const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    EightyMusic(),
                    MixesMaisOuvidos(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
