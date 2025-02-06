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

// Classe que serve como Tela Principal.
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
  // Backup dos IDs.
  List<String> backupList = [];
  List<String> backupMixes = [];

  // Map com informações das Músicas.
  Set<Map<String, String>> mapListMusics = {};
  Set<Map<String, String>> mapMixesInfo = {};

  // Set para saber se carregou tudo ou não.
  Set<String> isLoading = {};

  // Atualiza o Map com informações da nova Lista/Mixes.
  Future<void> updateMap(String file) async {
    await widget.group.loadMap(file);

    switch (file) {
      case 'list':
        mapListMusics = widget.group.listMap;
      case 'mixes':
        mapMixesInfo = widget.group.mixesMap;
    }
  }

  // Pega os dados do Firebase e atualiza os arquivos salvos no cache.
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

  // Atualiza os Backups e Maps com os dados que foram salvos.
  Future<void> loadAllSaved() async {
    backupList = widget.group.list;
    backupMixes = widget.group.mixes;

    mapListMusics = widget.group.listMap;
    mapMixesInfo = widget.group.mixesMap;

    isLoading.add('List');
    isLoading.add('Mixes');
  }

  @override
  void initState() {
    super.initState();

    // Caso o usuário seja diferente.
    if (widget.group.token != FirebaseAuth.instance.currentUser!.uid) {
      // Explicação se encontra na Função.
      loadFiles().then((value) {
        setState(() {});
      });
    } else {
      // Explicação se encontra na Função.
      loadAllSaved().then((value) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pega o tamanho da tela e armazena.
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
              // Vai para trocar_playlist.
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => TrocarPlaylist(
                            group: widget.group,
                          )))
                  .then((value) async {
                if (context.mounted) {
                  // Tela de Carregamento.
                  LoadScreen().loadingScreen(context);
                }

                bool loadAgain = false;

                // Verifica se a lista foi modificada.
                if (widget.group.get('list').length != backupList.length) {
                  // Explicação se encontra na Função.
                  await updateMap('list');
                  backupList = widget.group.get('list');
                  loadAgain = true;
                }

                // Verifica se o mixes foi modificada.
                if (widget.group.get('mixes').length != backupMixes.length) {
                  // Explicação se encontra na Função.
                  await updateMap('mixes');
                  backupMixes = widget.group.get('mixes');
                  loadAgain = true;
                }

                // Caso lista ou mixes seja modificada.
                if (loadAgain) {
                  // Pega a lista e mixes salvado no cache.
                  String lista = await ControleArquivo().getFile('list');
                  String mixes = await ControleArquivo().getFile('mixes');

                  // Faz update nos dados do Firebase.
                  Database().updateDataBase().update({
                    'Apelido': widget.group.apelido,
                    'Lista': lista,
                    'Mixes': mixes,
                  });
                }

                if (context.mounted) {
                  // vai para tela_inicial.
                  Navigator.of(context).pushNamed('/inicio');
                }
              });
            }
          },
          child: Icon(
            Icons.add,
            color: isLoading.length != 2
                ? Colors.green.withOpacity(0.5)
                : Colors.green,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (isLoading.length == 2) {
                  // Aparece um pop-up.
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text(
                            'Tem certeza?',
                            style: TextStyle(fontSize: size.height * 0.03),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      // Vai para tela_login.
                                      Navigator.of(context).pushNamed('/');
                                    },
                                    child: Text(
                                      'Sim',
                                      style: TextStyle(
                                        fontSize: size.height * 0.025,
                                        color: Colors.green,
                                      ),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      // Remove a tela que está no topo.
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Não',
                                      style: TextStyle(
                                        fontSize: size.height * 0.025,
                                        color: Colors.red,
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        );
                      });
                }
              },
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'Deslogar ',
                  style: TextStyle(
                    fontSize: size.height * 0.018,
                    color: isLoading.length != 2
                        ? Colors.red.withOpacity(0.5)
                        : Colors.red,
                  ),
                ),
                Icon(
                  Icons.logout,
                  color: isLoading.length != 2
                      ? Colors.red.withOpacity(0.5)
                      : Colors.red,
                ),
              ])),
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
              // Tela de Carregamento
              ? LoadScreen().loadingNormal(size)
              : (mapListMusics.isEmpty && mapMixesInfo.isEmpty)
                  ? Center(
                      heightFactor: 2.1,
                      child: Column(
                        children: [
                          // Coloca o ícone com as cores preto e branco na tela com tamaho especificado e forma oval.
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
                          // Dar um espaço entre os Widget's.
                          SizedBox(height: size.height * 0.01),
                          // Texto
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
                            // Classe ListMusic.
                            ListMusic(
                              mapListMusics: mapListMusics,
                              group: widget.group,
                            ),
                            // Classe MixesMaisOuvidos.
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
