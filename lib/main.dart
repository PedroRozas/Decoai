import 'package:deciaiv2/home.dart';
import 'package:deciaiv2/stylebyimage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deco AI',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const Design(),
    );
  }
}
