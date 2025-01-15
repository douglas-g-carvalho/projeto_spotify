import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/constants.dart';
import 'package:spotify/spotify.dart';

class Groups extends ChangeNotifier {
  // rework total
  List<String> list = [];
  List<String> mixes = [];

  List<Map<String, String>> listMap = [];
  List<Map<String, String>> mixesMap = [];

  final Map<int, Map<String, String>> _mapListMusics = {};
  final Map<int, Map<String, String>> _mapMixesInfo = {};

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

  Map<int, Map<String, String>> getMap(String file) {
    switch (file) {
      case 'list':
        return {..._mapListMusics};
      case 'mixes':
        return {..._mapMixesInfo};
      case _:
        return {};
    }
  }

  void addMap(String file, int index, String key, String value) {
    switch (file) {
      case 'list':
        if (!_mapListMusics.containsKey(index)) {
          _mapListMusics.addAll({
            index: {key: value}
          });
        } else {
          _mapListMusics[index]!.addAll({key: value});
        }
      case 'mixes':
        if (!_mapMixesInfo.containsKey(index)) {
          _mapMixesInfo.addAll({
            index: {key: value}
          });
        } else {
          _mapMixesInfo[index]!.addAll({key: value});
        }
    }

    notifyListeners();
  }

  void removeMap(String file, int index) {
    switch (file) {
      case 'list':
        _mapListMusics.remove(index);
      case 'mixes':
        _mapMixesInfo.remove(index);
    }

    notifyListeners();
  }

  Future<void> loadMap(String file) async {
    final credentials =
        SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = SpotifyApi(credentials);

    List<String> id = [];
    switch (file) {
      case 'list':
        id = list;
      case 'mixes':
        id = mixes;
    }

    for (int index = 0; index != id.length; index++) {
      await spotify.playlists.get(id[index]).then((value) {
        switch (file) {
          case 'list':
            try {
              addMap('list', index, 'name', value.name!);
              addMap('list', index, 'cover', value.images!.first.url!);
              addMap('list', index, 'spotify', value.id!);
            } catch (error) {
              removeMap('list', index);
              index -= 1;
            }
          case 'mixes':
            try {
              addMap('mixes', index, 'ID', value.id!);
              addMap('mixes', index, 'Name', value.name!);
              addMap('mixes', index, 'Image', value.images!.first.url!);
            } catch (error) {
              removeMap('mixes', index);
              index -= 1;
            }
        }
      });
    }
    notifyListeners();
  }
}
