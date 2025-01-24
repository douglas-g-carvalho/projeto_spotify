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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
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

  final group = Groups();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Musical Wizard',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Constants.color),
        useMaterial3: true,
      ),
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
