import 'package:flutter/material.dart';

import 'package:spotify/spotify.dart';
import 'package:projeto_spotify/Utils/controle_arquivo.dart';

import '../Utils/efficiency_utils.dart';
import '../Utils/groups.dart';

// Classe para realizar a troca da Lista e Mixes.
class TrocarPlaylist extends StatefulWidget {
  final Groups group;

  const TrocarPlaylist({
    super.key,
    required this.group,
  });

  @override
  State<TrocarPlaylist> createState() => _TrocarPlaylistState();
}

class _TrocarPlaylistState extends State<TrocarPlaylist> {
  // Inicia o Controle de Arquivo.
  final storage = ControleArquivo();

  Future<void> bottomError(texto, size, context) =>
      ErrorMessage().bottomSheetError(
        texto: texto,
        size: size,
        context: context,
      );

  // Controle de Texto para o TextFormField.
  late TextEditingController controller;

  // Backup da database.
  dynamic databaseBackup = {};

  // Cria um Texto personalizado com o botão de deletar no lado.
  Widget rowText(Size size, int index) {
    Set<Map<String, String>> name = widget.group.idMusicMap;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: size.width * 0.60,
          child: Text(
            name.elementAt(index)['name'] ?? '',
            style: TextStyle(color: Colors.white, fontSize: size.width * 0.05),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () async {
            LoadScreen().loadingScreen(context);

            Set<Map<String, String>> removeMap = widget.group.idMusicMap;

            await storage.update(removeMap.elementAt(index)['spotify']!);

            await storage.readCounter().then((value) {
              widget.group.idMusic = value;
            }).then((value) {
              widget.group.idMusicMap
                  .remove(widget.group.idMusicMap.elementAt(index));

              setState(() {});
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
          },
          child: const Icon(
            Icons.close,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  // Botão de adicionar personalizado.
  Future<void> add(Size size) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            actions: [
              TextField(
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: ' Coloque o ID do Spotify'),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.height * 0.02,
                ),
                cursorColor: Colors.white,
                keyboardType: TextInputType.text,
                controller: controller,
                onSubmitted: (String value) async {
                  if (value != '') {
                    LoadScreen().loadingScreen(context);

                    final credentials = SpotifyApiCredentials(
                        Constants.clientId, Constants.clientSecret);
                    final spotify = SpotifyApi(credentials);

                    bool haveError = false;

                    try {
                      // Verifica se o ID existe na Playlist ou Albums.
                      try {
                        await spotify.playlists.get(value);
                      } catch (error) {
                        try {
                          await spotify.albums.get(value);
                        } catch (error) {
                          haveError = true;
                          throw Error;
                        }
                      }

                      await ControleArquivo().writeAdd(value);

                      await ControleArquivo().readCounter().then((value) {
                        widget.group.idMusic = value;
                      });

                      await widget.group.loadMap().then((value) {
                        setState(() {});
                      });
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                      controller.text = '';
                    } catch (error) {
                      haveError = true;
                      // caso não encontre a playlist volta para o textField.
                    }

                    if (mounted) {
                      Navigator.of(context).pop();
                      if (haveError) {
                        await bottomError(
                          'ID não encontrado.',
                          size,
                          context,
                        );
                      }
                    }
                  }
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();

    // Atribuindo o Editor de Texto.
    controller = TextEditingController();
  }

  // Função do Flutter para quando a Página fechar.
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pega o tamanho da tela e armazena.
    final size = MediaQuery.of(context).size;
    // Salva o tamanho do StatusBar.
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
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.purple.shade900,
              Colors.green.shade900,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5),
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'Trocar Playlist',
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.065,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Mostra um pop-up.
                  // Modificar o pop-up apenas para sim ou não e restaurar o ID Music.
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.5),
                    builder: (ctx) {
                      return AlertDialog(
                        title: Text(
                          'Deseja Restaurar?',
                          style: TextStyle(fontSize: size.width * 0.065),
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  // Tela de Carregamento.
                                  LoadScreen().loadingScreen(context);

                                  // Explicação se encontra na Função.
                                  await Database()
                                      .updateDataBase()
                                      .get()
                                      .then((value) {
                                    databaseBackup = value.value!;
                                  });

                                  // Explicação se encontra na Função.
                                  await storage.delete().then((value) async {
                                    try {
                                      // Explicação se encontra na Função.
                                      await ControleArquivo().writeAdd(
                                          widget.group.limpadoraID(
                                              databaseBackup['ID Music']));

                                      // Explicação se encontra na Função.
                                      await ControleArquivo()
                                          .readCounter()
                                          .then((value) {
                                        widget.group.idMusic = value;
                                      });

                                      // Explicação se encontra na Função.
                                      await widget.group
                                          .loadMap()
                                          .then((value) {
                                        setState(() {});
                                      });
                                    } catch (error) {
                                      // caso não encontre a playlist volta para o textField.
                                    }
                                  });

                                  if (context.mounted) {
                                    // Remove a tela que está no topo.
                                    Navigator.of(context).pop();
                                    // Remove a tela que está no topo.
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text(
                                  'Sim',
                                  style: TextStyle(
                                    fontSize: size.width * 0.07,
                                    color:
                                        const Color.fromARGB(255, 52, 143, 55),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Não',
                                  style: TextStyle(
                                    fontSize: size.width * 0.07,
                                    color: Colors.red,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.restore,
                  color: Colors.white,
                  size: size.width * 0.08,
                ),
              ),
            ],
            centerTitle: true,
            backgroundColor: Colors.black,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Usado para centralizar o Texto e Ícone.
                      Text('       '),
                      // Texto Principal.
                      Text(
                        'ID Music',
                        style: TextStyle(
                          fontSize: size.width * 0.06,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      // TextButton de + para adicionar conteúdo no ID Music.
                      TextButton(
                        onPressed: () async {
                          // faz o input aparecer e verificar se existe o link
                          await add(size);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              Size(size.width * 0.01, size.height * 0.005),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                // Retângulo com nomes dos ID's.
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                  ),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: size.width * 0.80,
                      height: size.height * 0.815,
                      child: ListView.builder(
                          itemCount: widget.group.idMusicMap.length,
                          itemBuilder: (ctx, index) {
                            return rowText(size, index);
                          }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
