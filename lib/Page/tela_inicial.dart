import 'package:flutter/material.dart';

import 'package:projeto_spotify/Utils/load_screen.dart';
import 'package:projeto_spotify/Widget/mixes_mais_ouvidos.dart';
import 'package:projeto_spotify/Page/trocar_playlist.dart';

import '../Utils/controle_arquivo.dart';
import '../Utils/groups.dart';
import '../Widget/list_music.dart';

class TelaInicial extends StatefulWidget {
  final Groups group;

  const TelaInicial({
    required this.group,
    super.key,
  });

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  List<String> backupList = [];
  List<String> backupMixes = [];

  Set<Map<String, String>> mapListMusics = {};
  Set<Map<String, String>> mapMixesInfo = {};

  Set<String> isLoading = {};

  Future<void> updateMap(String file) async {
    LoadScreen().loadingScreen(context);

    await widget.group.loadMap(file).then((value) {
      switch (file) {
        case 'list':
          mapListMusics = widget.group.listMap;
        case 'mixes':
          mapMixesInfo = widget.group.mixesMap;
      }

      setState(() {});
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    });
  }

  Future<void> loadFiles() async {
    await ControleArquivo().readCounter('list').then((value) async {
      if (value.isEmpty) {
        await ControleArquivo()
            .writeCounter('list',
                '6AsR0V6KWciPEVnZfIFKnX-/-2AltltuDppkFyGloecxjzs-/-6bpPKPIWEPnvLmqRc7GLzw-/-08eJerYHHTin58iXQjQHpK-/-5tEzEAdmKqsugZxOq9YajR-/-60egqvG5M5ilZM8Js4hCkG-/-7234K2ZNVmAfetWuSguT7V-/-0Mgok0vqQjNAsLV5WyJvAq')
            .then((value) async {
          await ControleArquivo().readCounter('list').then((value) {
            widget.group.list = value;
            backupList = value;
          });
        });
      } else {
        widget.group.list = value;
        backupList = value;
      }
    }).then((value) async {
      if (widget.group.listMap.isNotEmpty) {
        mapListMusics = widget.group.listMap;
      } else {
        await widget.group.loadMap('list').then((value) {
          mapListMusics = widget.group.listMap;
        });
      }

      isLoading.add('List');
    });

    await ControleArquivo().readCounter('mixes').then((value) async {
      if (value.isEmpty) {
        await ControleArquivo()
            .writeCounter('mixes',
                '6G4O7YRLjTk4T4VPa4fDAM-/-7w13RcdObCa0WvQrjVJDfp-/-5z2dTZUjDD90wM4Z9youwS')
            .then((value) async {
          await ControleArquivo().readCounter('mixes').then((value) {
            widget.group.mixes = value;
            backupMixes = value;
          });
        });
      } else {
        widget.group.mixes = value;
        backupMixes = value;
      }
    }).then((value) async {
      if (widget.group.mixesMap.isNotEmpty) {
        mapMixesInfo = widget.group.mixesMap;
      } else {
        await widget.group.loadMap('mixes').then((value) {
          mapMixesInfo = widget.group.mixesMap;
        });
      }

      isLoading.add('Mixes');
    });
  }

  @override
  void initState() {
    super.initState();

    loadFiles().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: TextButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => TrocarPlaylist(
                          group: widget.group,
                        )))
                .then((value) {
              if (widget.group.get('list').length != backupList.length) {
                updateMap('list');
                backupList = widget.group.get('list');
              }

              if (widget.group.get('mixes').length != backupMixes.length) {
                updateMap('mixes');
                backupMixes = widget.group.get('mixes');
              }
            });
          },
          child: const Icon(
            Icons.add,
            color: Colors.green,
          ),
        ),
      ),
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
          child: isLoading.length != 2
              ? LoadScreen().loadingNormal(size)
              : Column(
                  children: [
                    SizedBox(height: size.height * 0.01),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListMusic(
                          mapListMusics: mapListMusics,
                          group: widget.group,
                        ),
                        MixesMaisOuvidos(
                          group: widget.group,
                          mapMixesInfo: mapMixesInfo,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
