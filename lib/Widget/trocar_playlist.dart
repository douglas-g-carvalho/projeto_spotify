import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/controle_arquivo.dart';

import 'package:spotify/spotify.dart';
import 'package:projeto_spotify/Utils/constants.dart';

import '../Utils/groups.dart';

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
  Future<List<Map<String, String>>> getNameFromSpotify(
      List<String> listID, List<Map<String, String>> newList) async {
    if (listID.isEmpty) {
      return [];
    }

    final credentials =
        SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = SpotifyApi(credentials);

    for (int index = 0; index != listID.length; index++) {
      await spotify.playlists.get(listID[index]).then((value) {
        try {
          newList.add({listID[index]: value.name!});
        } catch (error) {
          newList.remove(newList[index]);
          index -= 1;
        }
      });
    }
    return newList;
  }

  final storage = ControleArquivo();

  Widget rowText(String file, Size size, String text, int index) {
    List<Map<String, String>> name = [];

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
            name[index][text] ?? '',
            style: TextStyle(color: Colors.white, fontSize: size.width * 0.05),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () async {
            await storage.update(file, text);

            await storage.readCounter(file).then((value) {
              setState(() {
                switch (file) {
                  case 'list':
                    widget.group.list = value;

                  case 'mixes':
                    widget.group.mixes = value;
                }

                name.remove(name[index]);
              });
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (widget.group.list.isNotEmpty && widget.group.listMap.isEmpty) {
      getNameFromSpotify(widget.group.list, widget.group.listMap).then((value) {
        setState(() {
          widget.group.listMap = value;
        });
      });
    }

    if (widget.group.mixes.isNotEmpty && widget.group.mixesMap.isEmpty) {
      getNameFromSpotify(widget.group.mixes, widget.group.mixesMap)
          .then((value) {
        setState(() {
          widget.group.mixesMap = value;
        });
      });
    }

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
                        title: Text(
                          'escolha qual deseja restaurar',
                          style: TextStyle(fontSize: size.width * 0.05),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () {
                                  storage.delete('list').then((value) {
                                    storage
                                        .writeCounter('list',
                                            '6AsR0V6KWciPEVnZfIFKnX-/-2AltltuDppkFyGloecxjzs-/-6bpPKPIWEPnvLmqRc7GLzw-/-08eJerYHHTin58iXQjQHpK-/-5tEzEAdmKqsugZxOq9YajR-/-60egqvG5M5ilZM8Js4hCkG-/-7234K2ZNVmAfetWuSguT7V-/-0Mgok0vqQjNAsLV5WyJvAq')
                                        .then((value) {
                                      storage.readCounter('list').then((value) {
                                        widget.group.list = value;
                                        widget.group.listMap = [];
                                        getNameFromSpotify(widget.group.list,
                                                widget.group.listMap)
                                            .then((value) {
                                          setState(() {
                                            widget.group.listMap = value;
                                          });
                                        });
                                      });
                                    });
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Lista',
                                  style: TextStyle(fontSize: size.width * 0.07),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  storage.delete('mixes').then((value) {
                                    storage
                                        .writeCounter('mixes',
                                            '6G4O7YRLjTk4T4VPa4fDAM-/-7w13RcdObCa0WvQrjVJDfp-/-5z2dTZUjDD90wM4Z9youwS')
                                        .then((value) {
                                      storage
                                          .readCounter('mixes')
                                          .then((value) {
                                        widget.group.mixes = value;
                                        widget.group.mixesMap = [];
                                        getNameFromSpotify(widget.group.mixes,
                                                widget.group.mixesMap)
                                            .then((value) {
                                          setState(() {
                                            widget.group.mixesMap = value;
                                          });
                                        });
                                      });
                                    });
                                  });
                                  Navigator.of(context).pop();
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
      body: widget.group.listMap.isEmpty && widget.group.mixesMap.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(size.width * 0.01, size.height * 0.005),
                      ),
                      child: const Icon(Icons.add_circle_outline),
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
                          return rowText(
                              'list', size, widget.group.list[index], index);
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
                        // fazer o input aparecer e verificar se existe o link
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(size.width * 0.01, size.height * 0.005),
                      ),
                      child: const Icon(Icons.add_circle_outline),
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
                            return rowText('mixes', size,
                                widget.group.mixes[index], index);
                          })),
                ),
              ),
            ]),
    );
  }
}
