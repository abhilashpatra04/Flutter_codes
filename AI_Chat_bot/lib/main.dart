import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gemini_chat_app/Screens/home.dart';
import 'package:gemini_chat_app/consts.dart';

void main() {
  Gemini.init(apiKey: Gemini_Api_Key);
  runApp(
    const MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 44, 179, 233)
        ),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
  
}

