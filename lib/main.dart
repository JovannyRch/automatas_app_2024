import 'package:automatas_2024/const/const.dart';
import 'package:automatas_2024/screens/HomeScreen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: APP_NAME,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
