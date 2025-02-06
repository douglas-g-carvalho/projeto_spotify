import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/constants.dart';
import 'package:spotify/spotify.dart';

//  Classe criada para deixar tudo pré-carregado após a primeira vez entrando no aplicativo.
class Groups extends ChangeNotifier {

  // Salvando informações recebidas do Firebase.
  String token = '';
  String apelido = '';

  // List's principais usados no aplicativo.
  List<String> list = [];
  List<String> mixes = [];

  // Map's principais usados no aplicativo.
  Set<Map<String, String>> listMap = {};
  Set<Map<String, String>> mixesMap = {};

  // Função para mandar uma cópia de uma das List's.
  List<String> get(String file) {
    switch (file) {
      case 'list':
        return [...list];
      case 'mixes':
        return [...mixes];
      case _:
        return [];
    }
  }

  // Função para pesquisar o conteúdo no arquivo pedido e salvar no Map correspondente.
  Future<void> loadMap(String file) async {
    final credentials =
        SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = SpotifyApi(credentials);

    List<String> id = [];
    Set<Map<String, String>> newMap = {};

    switch (file) {
      case 'list':
        id = list;

      case 'mixes':
        id = mixes;
    }

    for (int index = 0; index != id.length; index++) {
      await spotify.playlists.get(id[index]).then((value) {
        try {
          newMap.add({
            'name': value.name!,
            'cover': value.images!.first.url!,
            'spotify': value.id!
          });
        } catch (error) {
          newMap.elementAt(index);
          index -= 1;
        }
      });
    }

    switch (file) {
      case 'list':
        listMap = newMap;
      case 'mixes':
        mixesMap = newMap;
    }

    notifyListeners();
  }
}
