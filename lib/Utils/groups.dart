import 'package:flutter/material.dart';

class Groups extends ChangeNotifier {
  // Eighty Music
  final List<String> _listGroups = [
    '6AsR0V6KWciPEVnZfIFKnX',
    '2AltltuDppkFyGloecxjzs',
    '6bpPKPIWEPnvLmqRc7GLzw',
    '08eJerYHHTin58iXQjQHpK',
    '5tEzEAdmKqsugZxOq9YajR',
    '60egqvG5M5ilZM8Js4hCkG',
    '7234K2ZNVmAfetWuSguT7V',
    '0Mgok0vqQjNAsLV5WyJvAq',
  ];

  final Map<int, Map<String, String>> _mapMusics = {};

  List<String> getListGroup() {
    return [..._listGroups];
  }

  Map<int, Map<String, String>> getMapMusics() {
    return {..._mapMusics};
  }

  void addMapMusics(int index, String key, String value) {
    if (!_mapMusics.containsKey(index)) {
      _mapMusics.addAll({
        index: {key: value}
      });
    } else {
      _mapMusics[index]!.addAll({key: value});
    }

    notifyListeners();
  }

  void removeMapMusics(int index) {
    _mapMusics.remove(index);
    notifyListeners();
  }

  // Mixes mais ouvidos
  final List<String> _mixes = [
    '6G4O7YRLjTk4T4VPa4fDAM',
    '7w13RcdObCa0WvQrjVJDfp',
    '5z2dTZUjDD90wM4Z9youwS',
  ];

  final Map<int, Map<String, String>> _mapInfo = {};

  List<String> getMixes() {
    return [..._mixes];
  }

  Map<int, Map<String, String>> getMapInfo() {
    return {..._mapInfo};
  }

  void addMapInfo(int index, String key, String value) {
    if (!_mapInfo.containsKey(index)) {
      _mapInfo.addAll({
        index: {key: value}
      });
    } else {
      _mapInfo[index]!.addAll({key: value});
    }
    notifyListeners();
  }
}
