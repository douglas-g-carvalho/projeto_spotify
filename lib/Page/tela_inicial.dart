import 'package:flutter/material.dart';
import 'package:projeto_spotify/Widget/mixes_mais_ouvidos.dart';

import '../Utils/groups.dart';
import '../Widget/eighty_music.dart';

class TelaInicial extends StatefulWidget {
  final Groups group;
  const TelaInicial({required this.group, super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
              SizedBox(height: size.height * 0.04),
              Text(
                'Spotify Fake',
                style:
                    TextStyle(color: Colors.white, fontSize: size.width * 0.08),
              ),
              SizedBox(height: size.height * 0.01),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  EightyMusic(group: widget.group),
                  MixesMaisOuvidos(group: widget.group),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
