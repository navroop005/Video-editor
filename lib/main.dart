import 'package:flutter/material.dart';
import 'package:video_editor/editor.dart';
import 'package:video_editor/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      routes: {
        '/': (context) => const Home(),
        '/editor': (context) => const Editor(),
      },
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Colors.black87,
          actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 10),
        ),
      ),
    );
  }
}
