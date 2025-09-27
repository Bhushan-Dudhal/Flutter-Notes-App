import 'package:flutter/material.dart';
import 'package:notes_app/screen/notes_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:'Notes',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const NotesScreen(),
    );
  }
}


