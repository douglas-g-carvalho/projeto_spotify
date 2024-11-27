import 'package:flutter/material.dart';
import 'package:projeto_spotify/Geral/App%20Routes/app_routes.dart';
import 'package:projeto_spotify/Tocar%20M%C3%BAsica/play_music.dart';
import 'package:projeto_spotify/search/search.dart';

import 'Tela Inicial/tela_inicial.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spotify (Beta)',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routes: {
        AppRoutes.inicio: (ctx) => const TelaInicial(),
        AppRoutes.playMusic: (ctx) => const PlayMusic(),
        AppRoutes.buscar: (ctx) => const Search(),
      },
    );
  }
}
