// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/controle_arquivo.dart';

import 'package:spotify/spotify.dart';
import 'package:projeto_spotify/Utils/constants.dart';

import '../Utils/groups.dart';
import '../Utils/load_screen.dart';

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
  Future<Set<Map<String, String>>> getNameFromSpotify(
      List<String> listID, Set<Map<String, String>> newList) async {
    if (listID.isEmpty) {
      return {};
    }

    final credentials =
        SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = SpotifyApi(credentials);

    for (int index = 0; index != listID.length; index++) {
      await spotify.playlists.get(listID[index]).then((value) {
        try {
          newList.add({
            'name': value.name!,
            'cover': value.images!.first.url!,
            'spotify': value.id!
          });
        } catch (error) {
          newList.remove(newList.elementAt(index));
          index -= 1;
        }
      });
    }

    return newList;
  }

  final storage = ControleArquivo();

  late TextEditingController controller;
  String textSearch = '';

  Widget rowText(String file, Size size, int index) {
    Set<Map<String, String>> name = {};

    switch (file) {
      case 'list':
        name = widget.group.listMap;
      case 'mixes':
        name = widget.group.mixesMap;
    }

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

            Set<Map<String, String>> removeMap = {};

            switch (file) {
              case 'list':
                removeMap = widget.group.listMap;

              case 'mixes':
                removeMap = widget.group.mixesMap;
            }

            await storage.update(file, removeMap.elementAt(index)['spotify']!);

            await storage.readCounter(file).then((value) {
              switch (file) {
                case 'list':
                  widget.group.list = value;

                case 'mixes':
                  widget.group.mixes = value;
              }
            }).then((value) {
              switch (file) {
                case 'list':
                  widget.group.listMap
                      .remove(widget.group.listMap.elementAt(index));

                case 'mixes':
                  widget.group.mixesMap
                      .remove(widget.group.mixesMap.elementAt(index));
              }

              setState(() {});

              Navigator.of(context).pop();
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

  Future<void> add(Size size, String file) {
    String hint = '';

    switch (file) {
      case 'list':
        hint = 'da Lista';
      case 'mixes':
        hint = 'do Mix';
    }

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
                    hintText: 'Coloque o ID $hint'),
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

                    try {
                      await spotify.playlists
                          .get(value)
                          .then((valueSpotify) {});

                      await ControleArquivo().writeAdd(file, value);

                      await ControleArquivo().readCounter(file).then((value) {
                        switch (file) {
                          case 'list':
                            widget.group.list = value;
                          case 'mixes':
                            widget.group.mixes = value;
                        }
                      });

                      await getNameFromSpotify(widget.group.get(file), {})
                          .then((value) {
                        switch (file) {
                          case 'list':
                            widget.group.listMap = value;
                          case 'mixes':
                            widget.group.mixesMap = value;
                        }

                        setState(() {});
                      });

                      Navigator.of(context).pop();
                    } catch (error) {
                      // caso não encontre a playlist volta para o textField.
                    }
                    Navigator.of(context).pop();
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
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
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
                showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.5),
                    builder: (ctx) {
                      return AlertDialog(
                        actions: [
                          SizedBox(
                            height: size.height * 0.01,
                            child: const Placeholder(
                              color: Colors.transparent,
                            ),
                          ),
                          Text(
                            'escolha qual deseja restaurar',
                            style: TextStyle(fontSize: size.width * 0.050),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () {
                                  LoadScreen().loadingScreen(context);

                                  storage.delete('list').then((value) {
                                    storage
                                        .writeAdd(
                                      'list',
                                      '6AsR0V6KWciPEVnZfIFKnX-/-2AltltuDppkFyGloecxjzs-/-6bpPKPIWEPnvLmqRc7GLzw-/-08eJerYHHTin58iXQjQHpK-/-5tEzEAdmKqsugZxOq9YajR-/-60egqvG5M5ilZM8Js4hCkG-/-7234K2ZNVmAfetWuSguT7V-/-0Mgok0vqQjNAsLV5WyJvAq',
                                    )
                                        .then((value) {
                                      storage.readCounter('list').then((value) {
                                        widget.group.list = value;
                                        widget.group.listMap = {};

                                        getNameFromSpotify(
                                          widget.group.list,
                                          widget.group.listMap,
                                        ).then((value) {
                                          setState(() =>
                                              widget.group.listMap = value);

                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        });
                                      });
                                    });
                                  });
                                },
                                child: Text(
                                  'Lista',
                                  style: TextStyle(fontSize: size.width * 0.07),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  LoadScreen().loadingScreen(context);

                                  storage.delete('mixes').then((value) {
                                    storage
                                        .writeAdd(
                                      'mixes',
                                      '6G4O7YRLjTk4T4VPa4fDAM-/-7w13RcdObCa0WvQrjVJDfp-/-5z2dTZUjDD90wM4Z9youwS',
                                    )
                                        .then((value) {
                                      storage
                                          .readCounter('mixes')
                                          .then((value) {
                                        widget.group.mixes = value;
                                        widget.group.mixesMap = {};

                                        getNameFromSpotify(
                                          widget.group.mixes,
                                          widget.group.mixesMap,
                                        ).then((value) {
                                          setState(() =>
                                              widget.group.mixesMap = value);

                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        });
                                      });
                                    });
                                  });
                                },
                                child: Text(
                                  'Mixes',
                                  style: TextStyle(fontSize: size.width * 0.07),
                                ),
                              )
                            ],
                          ),
                        ],
                      );
                    });
              },
              child: Icon(
                Icons.restore,
                color: Colors.white,
                size: size.width * 0.08,
              ))
        ],
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'aaa',
                  style: TextStyle(color: Colors.transparent),
                ),
                Text(
                  'Lista',
                  style: TextStyle(
                    fontSize: size.width * 0.06,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // faz o input aparecer e verificar se existe o link
                    add(size, 'list');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(size.width * 0.01, size.height * 0.005),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
            ),
            child: SingleChildScrollView(
              child: SizedBox(
                width: size.width * 0.80,
                height: size.height * 0.37,
                child: ListView.builder(
                    itemCount: widget.group.listMap.length,
                    itemBuilder: (ctx, index) {
                      return rowText('list', size, index);
                    }),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.005),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'aaa',
                  style: TextStyle(color: Colors.transparent),
                ),
                Text(
                  'Mixes',
                  style: TextStyle(
                    fontSize: size.width * 0.06,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // faz o input aparecer e verificar se existe o link
                    add(size, 'mixes');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(size.width * 0.01, size.height * 0.005),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
            ),
            child: SingleChildScrollView(
              child: SizedBox(
                  width: size.width * 0.80,
                  height: size.height * 0.37,
                  child: ListView.builder(
                      itemCount: widget.group.mixesMap.length,
                      itemBuilder: (ctx, index) {
                        return rowText('mixes', size, index);
                      })),
            ),
          ),
        ]),
      ),
    );
  }
}
