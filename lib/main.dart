import 'package:flutter/material.dart';
import 'package:video_editor/editor.dart';
import 'package:video_editor/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      routes: {
        '/': (context) => const Home(),
        '/editor': (context) => const Editor(),
      },
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme.of(context).copyWith(
          backgroundColor: Colors.indigo[900],
        ),
      ),
    );
  }
}
