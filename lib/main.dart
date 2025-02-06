import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:projeto_spotify/Page/tela_login.dart';
import 'package:projeto_spotify/Utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:projeto_spotify/Page/search.dart';

import 'Utils/music_player.dart';
import 'Utils/app_routes.dart';
import 'Utils/groups.dart';

import 'Page/tela_inicial.dart';

// Classe padrão criada pelo Próprio Flutter para rodar o aplicativo.

void main() async {
  // usado para remover erro no terminal.
  WidgetsFlutterBinding.ensureInitialized();
  // inicia o Firebase.
  await Firebase.initializeApp();

  runApp(
    // MultiProvider para usar o ChangeNotifier com mais de um Provider.
    MultiProvider(
      providers: [
        Provider(create: (context) => MusicPlayer()),
        Provider(create: (context) => Groups()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Inicia o Groups para deixar salvo os arquivos e só precisar carrega-los uma vez.
  final group = Groups();

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
        AppRoutes.buscar: (ctx) => const Search(),
      },
    );
  }
}
