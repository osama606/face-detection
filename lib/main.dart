//import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'FaceDetector.dart';

void main() async {
  runApp(
    MaterialApp(
      title: "Face Detection",
      darkTheme: ThemeData.dark(),
      home: FaceDetector(),
    ),
  );
  await Firebase.initializeApp();
}
