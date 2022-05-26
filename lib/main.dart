import 'package:flutter/material.dart';
import 'package:video_editor/home.dart';
import 'editor.dart';
import 'home.dart';

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
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
            ),
      ),
    );
  }
}
