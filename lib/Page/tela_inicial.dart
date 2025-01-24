import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_spotify/Utils/load_screen.dart';
import 'package:projeto_spotify/Widget/mixes_mais_ouvidos.dart';
import 'package:projeto_spotify/Page/trocar_playlist.dart';

import '../Utils/constants.dart';
import '../Utils/controle_arquivo.dart';
import '../Utils/database.dart';
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
    await widget.group.loadMap(file);

    switch (file) {
      case 'list':
        mapListMusics = widget.group.listMap;
      case 'mixes':
        mapMixesInfo = widget.group.mixesMap;
    }
  }

  Future<void> loadFiles() async {
    try {
      widget.group.token = FirebaseAuth.instance.currentUser!.uid;
      String listaDB = '';
      String mixesDB = '';

      await Database().dbRef.get().then((value) {
        Map info =
            value.child(FirebaseAuth.instance.currentUser!.uid).value as Map;

        widget.group.apelido = info['Apelido'];
        listaDB = info['Lista'];
        mixesDB = info['Mixes'];
      });

      await ControleArquivo().overWrite('list', listaDB);
      await ControleArquivo().overWrite('mixes', mixesDB);

      widget.group.list = await ControleArquivo().readCounter('list');
      widget.group.mixes = await ControleArquivo().readCounter('mixes');

      backupList = widget.group.list;
      backupMixes = widget.group.mixes;

      await widget.group.loadMap('list');
      await widget.group.loadMap('mixes');

      mapListMusics = widget.group.listMap;
      mapMixesInfo = widget.group.mixesMap;

      isLoading.add('List');
      isLoading.add('Mixes');
    } catch (error) {
      isLoading.add('List');
      isLoading.add('Mixes');
    }
  }

  Future<void> loadAllSaved() async {
    mapListMusics = widget.group.listMap;
    mapMixesInfo = widget.group.mixesMap;

    isLoading.add('List');
    isLoading.add('Mixes');
  }

  @override
  void initState() {
    super.initState();

    if (widget.group.token != FirebaseAuth.instance.currentUser!.uid) {
      loadFiles().then((value) {
        setState(() {});
      });
    } else {
      loadAllSaved().then((value) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (isLoading.length == 2) ? widget.group.apelido : '',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: TextButton(
          onPressed: () {
            if (isLoading.length == 2) {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => TrocarPlaylist(
                            group: widget.group,
                          )))
                  .then((value) async {
                if (context.mounted) {
                  LoadScreen().loadingScreen(context);
                }

                if (widget.group.get('list').length != backupList.length) {
                  await updateMap('list');
                  backupList = widget.group.get('list');
                }

                if (widget.group.get('mixes').length != backupMixes.length) {
                  await updateMap('mixes');
                  backupMixes = widget.group.get('mixes');
                }

                String lista = await ControleArquivo().getFile('list');
                String mixes = await ControleArquivo().getFile('mixes');

                Database().updateDataBase().update({
                  'Apelido': widget.group.apelido,
                  'Lista': lista,
                  'Mixes': mixes,
                });

                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                setState(() {});
              });
            }
          },
          child: Icon(
            Icons.add,
            color: isLoading.length != 2
                ? Constants.color.withOpacity(0.5)
                : Constants.color,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (isLoading.length == 2) {
                  Navigator.of(context).pushNamed('/');
                }
              },
              child: Icon(
                Icons.account_circle,
                size: size.height * 0.04,
                color: isLoading.length != 2
                    ? Constants.color.withOpacity(0.5)
                    : Constants.color,
              )),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedIconTheme: const IconThemeData(color: Constants.color),
        unselectedIconTheme: const IconThemeData(color: Colors.white),
        selectedItemColor: Constants.color,
        unselectedItemColor: Colors.white,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                color: isLoading.length != 2
                    ? Constants.color.withOpacity(0.5)
                    : Constants.color,
              ),
              label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: isLoading.length != 2
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white,
              ),
              label: 'Buscar'),
        ],
        onTap: isLoading.length != 2
            ? null
            : (value) {
                switch (value) {
                  case 0:
                    Navigator.pushNamed(context, '/inicio');
                  case 1:
                    Navigator.pushNamed(context, '/buscar');
                }
              },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: isLoading.length != 2
              ? LoadScreen().loadingNormal(size)
              : (mapListMusics.isEmpty && mapMixesInfo.isEmpty)
                  ? Center(
                      heightFactor: 2.1,
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.30,
                            child: ClipOval(
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    Colors.grey, BlendMode.saturation),
                                child: Image.asset('assets/icon.png'),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            'Lista e Mixes estão vazias.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.height * 0.03),
                          )
                        ],
                      ),
                    )
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
