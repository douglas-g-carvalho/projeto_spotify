import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_spotify/Page/select_music.dart';
import 'package:projeto_spotify/Page/trocar_playlist.dart';

import '../Utils/controle_arquivo.dart';
import '../Utils/efficiency_utils.dart';
import '../Utils/groups.dart';

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
  List<String> backupIdMusic = [];

  // Map com informações das Músicas.
  Set<Map<String, String>> mapIdMusic = {};

  // Set para saber se carregou tudo ou não.
  bool isLoading = true;

  // Atualiza o Map com informações novas.
  Future<void> updateMap() async {
    await widget.group.loadMap();

    mapIdMusic = widget.group.idMusicMap;
  }

  // Pega os dados do Firebase e atualiza os arquivos salvos no cache.
  Future<void> loadFiles() async {
    try {
      widget.group.token = FirebaseAuth.instance.currentUser!.uid;
      String idMusic = '';

      await widget.group.dbRef.dbRefInfo
          .child(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        Map info = value.value as Map;

        widget.group.apelido = info['Apelido'];
        idMusic = info['ID Music'];
      });

      await ControleArquivo().overWrite(idMusic);

      widget.group.idMusic = await ControleArquivo().readCounter();

      backupIdMusic = widget.group.idMusic;

      await widget.group.loadMap();

      mapIdMusic = widget.group.idMusicMap;

      isLoading = false;
    } catch (error) {
      isLoading = false;
    }
  }

  // Atualiza o Backups e Map com os dados que foram salvos.
  Future<void> loadAllSaved() async {
    backupIdMusic = widget.group.idMusic;
    mapIdMusic = widget.group.idMusicMap;
    isLoading = false;
  }

  @override
  void initState() {
    super.initState();

    // Caso o usuário seja diferente.
    if (widget.group.token != FirebaseAuth.instance.currentUser!.uid) {
      // Explicação se encontra na Função.
      loadFiles().then((value) async {
        setState(() {});
      });
    } else {
      // Explicação se encontra na Função.
      loadAllSaved().then((value) async {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pega o tamanho da tela e armazena.
    final size = MediaQuery.of(context).size;
    final appBarSize = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: appBarSize,
        backgroundColor: Colors.black,
        leading: TextButton(
          onPressed: null,
          child: Icon(
            Icons.ac_unit_outlined,
            color: Colors.transparent,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Colors.blue, Colors.yellow])),
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.75),
          appBar: AppBar(
            title: Text(
              (!isLoading) ? widget.group.apelido : '',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            leading: TextButton(
              onPressed: () {
                if (!isLoading) {
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

                    for (String index in backupIdMusic) {
                      if (!widget.group.get().contains(index) ||
                          widget.group.get().length != backupIdMusic.length) {
                        await updateMap();
                        backupIdMusic = widget.group.get();
                        loadAgain = true;
                        break;
                      }
                    }

                    // Caso ID Music seja modificado.
                    if (loadAgain) {
                      // Pega o ID Music salvado no cache.
                      String idMusic = await ControleArquivo().getFile();

                      // Faz update nos dados do Firebase.
                      widget.group.dbRef.updateDataBase().update({
                        'Apelido': widget.group.apelido,
                        'ID Music': widget.group.limpadoraID(idMusic),
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
                color: isLoading ? Colors.green.withOpacity(0.5) : Colors.green,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    if (!isLoading) {
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                            color: const Color.fromARGB(
                                                255, 52, 143, 55),
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
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Deslogar ',
                          style: TextStyle(
                            fontSize: size.height * 0.018,
                            color: isLoading
                                ? Colors.red.withOpacity(0.5)
                                : Colors.red,
                          ),
                        ),
                        Icon(
                          Icons.logout,
                          color: isLoading
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
                    color: isLoading
                        ? Constants.color.withOpacity(0.5)
                        : Constants.color,
                  ),
                  label: 'Inicio'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.search,
                    color: isLoading
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                  ),
                  label: 'Buscar'),
            ],
            onTap: isLoading
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
              child: isLoading
                  // Tela de Carregamento
                  ? LoadScreen().loadingNormal(size)
                  : (mapIdMusic.isEmpty)
                      // Logo (em preto e branco) e Texto avisando que a lista está vazia.
                      ? Center(
                          heightFactor: 2,
                          child: Column(
                            children: [
                              // Coloca o ícone com as cores preto e branco na tela com tamaho especificado e forma oval.
                              SizedBox(
                                height: size.height * 0.35,
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
                                'ID Music está vazio.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.height * 0.03),
                              )
                            ],
                          ),
                        )
                      // Lista das músicas.
                      : Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Seleção de Música.
                                SelectMusic(
                                  group: widget.group,
                                ),
                              ],
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
