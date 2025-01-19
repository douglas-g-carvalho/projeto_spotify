import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/groups.dart';
import 'package:provider/provider.dart';

import 'package:projeto_spotify/Utils/music_player.dart';
import 'package:projeto_spotify/Utils/app_routes.dart';
import 'package:projeto_spotify/Page/search.dart';

import 'Page/tela_inicial.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      title: 'Spotify (Beta)',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routes: {
        AppRoutes.inicio: (ctx) => TelaInicial(
              group: group,
            ),
        AppRoutes.buscar: (ctx) => const Search(),
      },
    );
  }
}
