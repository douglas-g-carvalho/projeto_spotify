import 'package:flutter/material.dart';

import 'package:spotify/spotify.dart';

import 'package:projeto_spotify/Utils/audio_player_handler.dart';
import 'package:projeto_spotify/Utils/efficiency_utils.dart';

//  Classe criada para deixar tudo pré-carregado após a primeira vez entrando no aplicativo.
class Groups extends ChangeNotifier {
  // Referência ao arquivo 'Informação' do Firebase.
  Database dbRef = Database();

  // Salvando informações recebidas do Firebase.
  String token = '';
  String apelido = '';

  late AudioPlayerHandler audioHandler;

  // List's principais usados no aplicativo.
  List<String> idMusic = [];

  // Map's principais usados no aplicativo.
  Set<Map<String, String>> idMusicMap = {};

  // Limpa a String da ID removendo os '-/-' desnecessários.
  String limpadoraID(String idMusic) {
    String idLimpa = '';

    List<String> listaSemSeparador = idMusic.split('-/-');

    listaSemSeparador.removeWhere((value) => value == '');
    for (String id in listaSemSeparador) {
      idLimpa += '$id-/-';
    }

    return idLimpa;
  }

  // Função para mandar uma cópia de uma das List's.
  List<String> get() {
    return [...idMusic];
  }

  // Função para pesquisar o conteúdo no arquivo pedido e salvar no Map correspondente.
  Future<void> loadMap() async {
    final credentials =
        SpotifyApiCredentials(Constants.clientId, Constants.clientSecret);
    final spotify = SpotifyApi(credentials);

    List<String> id = [];
    Set<Map<String, String>> newMap = {};

    id = idMusic;

    // Faz o teste com a ID para descobrir qual tipo Playlist ou Album.
    Future<void> testID(int index) async {
      try {
        // Testa com Playlists.
        await spotify.playlists.get(id[index]).then((value) {
          newMap.add({
            'name': value.name!,
            'cover': value.images!.first.url!,
            'spotify': value.id!,
            'total': value.tracks!.total.toString(),
          });
        });
      } catch (error) {
        try {
          // Testa com albums.
          await spotify.albums.get(id[index]).then((value) {
            newMap.add({
              'name': value.name!,
              'cover': value.images!.first.url!,
              'spotify': value.id!,
              'total': value.tracks!.length.toString(),
            });
          });
        } catch (error) {
          // Falha.
        }
      }
    }

    for (int index = 0; index != id.length; index++) {
      await testID(index);
    }

    idMusicMap = newMap;

    notifyListeners();
  }
}
