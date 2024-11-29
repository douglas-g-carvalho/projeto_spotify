import 'package:flutter/material.dart';
import 'package:projeto_spotify/Utils/app_routes.dart';
import 'package:projeto_spotify/Page/search.dart';

import 'Page/tela_inicial.dart';

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
        AppRoutes.buscar: (ctx) => const Search(),
      },
    );
  }
}
