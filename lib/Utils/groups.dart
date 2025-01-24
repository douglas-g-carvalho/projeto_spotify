import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/constants.dart';
import 'package:spotify/spotify.dart';

class Groups extends ChangeNotifier {
  String token = '';
  String apelido = '';

  List<String> list = [];
  List<String> mixes = [];

  Set<Map<String, String>> listMap = {};
  Set<Map<String, String>> mixesMap = {};

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
