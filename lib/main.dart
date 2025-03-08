import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:projeto_spotify/Page/tela_login.dart';
import 'package:projeto_spotify/Utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:projeto_spotify/Page/search.dart';

// import 'Utils/music_player.dart';
import 'Utils/app_routes.dart';
import 'Utils/groups.dart';
import 'Utils/audio_player_handler.dart';

import 'Page/tela_inicial.dart';

// Classe padrão criada pelo Próprio Flutter para rodar o aplicativo.
// Inicia o Groups para deixar salvo os arquivos e só precisar carrega-los uma vez.
final group = Groups();
Future<void> main() async {
  // usado para remover erro no terminal.
  WidgetsFlutterBinding.ensureInitialized();
  // inicia o Firebase.
  await Firebase.initializeApp();

  group.audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );

  // Inicia o aplicativo.
  runApp(
    // MultiProvider para usar o ChangeNotifier com mais de um Provider.
    MultiProvider(
      providers: [
        // Provider(create: (context) => MusicPlayer(group: Groups())),
        Provider(create: (context) => Groups()),
      ],
      child: MyApp(group: group),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Groups group;
  const MyApp({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove o Debug no canto da tela.
      debugShowCheckedModeBanner: false,
      title: 'Musical Wizard',
      // configura o Tema default dos Widgets.
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Constants.color),
        useMaterial3: true,
      ),
      // Rotas para navegação mais fácil.
      routes: {
        AppRoutes.login: (ctx) => TelaLogin(
              group: group,
            ),
        AppRoutes.inicio: (ctx) => TelaInicial(
              group: group,
            ),
        AppRoutes.buscar: (ctx) => Search(group: group),
      },
    );
  }
}
