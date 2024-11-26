import 'package:flutter/material.dart';
import 'package:videlay_app/components/video.dart';
import 'components/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Videlay',
      theme: ThemeData.dark(),
      home: CameraCapture(),
    );
  }
}
